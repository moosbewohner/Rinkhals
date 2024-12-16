import asyncio
import websockets
import json
import uuid
import time
import os

import aiohttp
from aiohttp import web

import paho.mqtt.client as paho



# User configuration
PRINTER_IP = os.getenv('MOONRAKER_PROXY_PRINTER_IP', default = '127.0.0.1')
PROXY_PORT = os.getenv('MOONRAKER_PROXY_PORT', default = '7125')
MOONRAKER_PORT = os.getenv('MOONRAKER_PROXY_MOONRAKER_PORT', default = '7126')

# Printer configuration
PRINTER_ID = os.getenv('MOONRAKER_PROXY_PRINTER_ID')
MQTT_USERNAME = os.getenv('MOONRAKER_PROXY_MQTT_USERNAME')
MQTT_PASSWORD = os.getenv('MOONRAKER_PROXY_MQTT_PASSWORD')
REMOTE_MODE = 'lan'

# Constants
CORS_HEADERS = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers": "*"
}



# HTTP proxy
async def http_options_handler(request):
    async with aiohttp.ClientSession() as session:
        return aiohttp.web.json_response({"message": "Accept all hosts"}, headers=CORS_HEADERS)
async def http_handler(request):
    async with aiohttp.ClientSession() as session:
        async with session.request(method = request.method, url = 'http://' + PRINTER_IP + ':' + MOONRAKER_PORT + request.raw_path, data = await request.read(), headers = request.headers) as response:
            return aiohttp.web.Response(status = response.status, body = await response.read(), headers = CORS_HEADERS)



# Websockets proxy
async def websocket_handler(request):
    client_ws = aiohttp.web.WebSocketResponse()
    await client_ws.prepare(request)

    async with websockets.connect('ws://' + PRINTER_IP + ':' + MOONRAKER_PORT + '/websocket') as backend_ws:

            async def client_loop():
                async for msg in client_ws:
                    if msg.type == aiohttp.WSMsgType.ERROR:
                        print('ws connection closed with exception %s' % ws.exception())
                        return

                    if msg.type == aiohttp.WSMsgType.TEXT:
                        if msg.data == 'close':
                            await ws.close()
                            return

                        data = json.loads(msg.data)
                        if "method" in data:
                            #print(data["method"]) 
                            
                            if data["method"] == "printer.print.start" and REMOTE_MODE == 'lan':

                                payload = """{{
                                    "type": "print",
                                    "action": "start",
                                    "msgid": "{0}",
                                    "timestamp": {1},
                                    "data": {{
                                        "taskid": "-1",
                                        "filename": "{2}",
                                        "filetype": 1
                                    }}
                                }}""".format(uuid.uuid4(), round(time.time() * 1000), data['params']['filename'])

                                client = paho.Client(client_id = "", userdata = None, protocol = paho.MQTTv5)
                                client.username_pw_set(MQTT_USERNAME, MQTT_PASSWORD)
                                client.connect(PRINTER_IP, 2883)
                                client.publish('anycubic/anycubicCloud/v1/slicer/printer/20024/' + PRINTER_ID + '/print', payload=payload, qos=1)

                                continue

                            if data["method"] == "server.files.metadata":
                                data['params']['filename'] = data['params']['filename'].replace('/useremain/app/gk/gcodes/', '')

                        await backend_ws.send(json.dumps(data))

            async def backend_loop():
                while True:
                    data = await backend_ws.recv()
                    await client_ws.send_str(data)

            await asyncio.gather(client_loop(), backend_loop())

    return client_ws



# Server config and startup
async def start_server():
    app = aiohttp.web.Application(client_max_size = None)
    app.add_routes([
        aiohttp.web.options('/{tail:.*}', http_options_handler),
        aiohttp.web.get('/websocket', websocket_handler),
        aiohttp.web.get('/{tail:.*}', http_handler),
        aiohttp.web.post('/{tail:.*}', http_handler),
    ])

    runner = aiohttp.web.AppRunner(app)
    await runner.setup()

    server = aiohttp.web.TCPSite(runner, "0.0.0.0", PROXY_PORT)
    await server.start()

if __name__ == "__main__":

    # We should use internal MQTT only if LAN mode is enabled
    with open('/useremain/dev/remote_ctrl_mode', 'r') as f:
        REMOTE_MODE = f.read().strip()

    # Retrieve printer information
    if not MQTT_USERNAME or not MQTT_PASSWORD:

        with open('/userdata/app/gk/config/device_account.json', 'r') as f:
            json_data = f.read()
            data = json.loads(json_data)

            if not MQTT_USERNAME:
                MQTT_USERNAME = data['username']
            if not MQTT_PASSWORD:
                MQTT_PASSWORD = data['password']

    if not PRINTER_ID:

        with open('/useremain/dev/device_id', 'r') as f:
            PRINTER_ID = f.read().strip()

    # Start asynchonous server
    loop = asyncio.get_event_loop()
    loop.run_until_complete(start_server())
    loop.run_forever()
