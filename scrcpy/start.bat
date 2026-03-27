@echo off
echo visit http://127.0.0.1:8003/admin/
echo username:root 
echo password:123
@echo on
.\py310\python.exe -m uvicorn django_scrcpy.asgi:application --host 0.0.0.0 --port 8003 --lifespan off