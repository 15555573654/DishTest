from django.http import HttpResponse
from django.db import models
from general.models import Mobile
from django.shortcuts import redirect
import datetime
def str_to_time(time_str):
    return datetime.datetime.strptime(time_str, "%Y-%m-%d %H:%M:%S")

def hello(request):
    if not request.user.is_superuser:
        return HttpResponse("权限不足")
    device_list = request.POST.get('device_list', '')
    user = request.POST.get('user', '')
    stop_time = request.POST.get('stop_time', '')
    result = device_list.split(",")
    dataIdList = []
    for value in result:
        dataIdList.append(int(value))
    Mobile.objects.filter(id__in=dataIdList).update(user_id = int(user),stop_time=str_to_time(stop_time))
    return redirect('/admin/general/mobile/')