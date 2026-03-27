import os
import json
import time
from typing import Any, Optional
from urllib.parse import quote
from django.db.models.query import QuerySet
from django.http.request import HttpRequest
from django.http import HttpResponse
from django.urls import reverse
from django.shortcuts import render
from django.contrib import admin
from django.contrib.auth.models import User
from django.utils.safestring import mark_safe
from django.template.context_processors import csrf
from django.core import serializers

from django.contrib import messages
from import_export.admin import ExportActionMixin

from general import forms
from general import models
from general import adb
from django_scrcpy.settings import MEDIA_ROOT


@admin.register(models.Mobile)
class MobileAdmin(ExportActionMixin, admin.ModelAdmin):
    save_on_top = True
    list_per_page = 100
    form = forms.MobileForm
    show_full_result_count = True
    search_fields = ['name']
    list_filter = ['device_type', 'user']
    list_display = ['id', 'online', 'user','device_id', 'device_name','stop_time', 'filemanager', 'updated_time', 'created_time']
    ordering = ['user']  # 设置默认排序字段
    actions = ['connect', 'disconnect', 'tcpip5555', 'AllScreen']


    def connect(self, request, queryset):
        for obj in queryset:
            adb.AdbDevice.connect(obj.device_id)
    connect.short_description = '连接'

    def Allauth(self, request, queryset):
        sql=""
        csrf_token = csrf(request)['csrf_token']
        for obj in queryset:
            sql=sql+f"{obj.id},"
        fields = User.objects.filter()
        userlist="";
        for obj in fields:
            userlist = userlist+f'<option value="{obj.id}"selected="">{obj}</option>'
        html=f'<link rel="stylesheet" href="/static/general/layui/css/layui.css"><script src="/static/general/layui/layui.js"></script><form class="layui-form layui-padding-2"id="form"lay-filter="form"action="/allauto/hello/" method="POST"><div class="layui-form-item adminj-sort-item"id="did_1715734505038_0"cpt_id="text"style="width: 100%;"><label class="layui-form-label">设备</label><div class="layui-input-inline"><input lay-verify="required" type="text"name="device_list"autocomplete="off" value="{sql.rstrip(",")}"class="layui-input layui-disabled"style="width: 99%;"></div><div class="layui-form-mid layui-word-aux"></div></div><div class="layui-form-item adminj-sort-item"id="did_1715734505043_1"cpt_id="select"style="width: 100%;"><label class="layui-form-label">所属用户</label><div class="layui-input-inline"><select name="user">{userlist}</select></div></div><div class="layui-form-item adminj-sort-item"id="did_1715734505045_2"cpt_id="date"style="width: 100%;"><label class="layui-form-label">到期时间</label><div class="layui-input-inline"><input type="text"name="stop_time"class="layui-input"id="stop_time"lay-verify="required" autocomplete="off"></div><div class="layui-form-mid layui-word-aux"></div></div><div id="did_1715736343791_3"class="layui-form-item adminj-sort-item"cpt_id="submitData"><div class="layui-input-block"><input type="hidden" name="csrfmiddlewaretoken" value="{csrf_token}"><button type="submit"class="layui-btn"lay-submit=""lay-filter="postButton"id="postButton">立即授权</button></div></div></form>'
        html=html+"<script>layui.use(function(){var laydate=layui.laydate;laydate.render({ elem:'#stop_time',type:'datetime' });});</script>" 
        return HttpResponse(html)
    Allauth.short_description = '批量授权'
    Allauth.style='background-color: #409eff !important;color: #fafafa;border-color: #409eff !important';


    def AllScreen(self, request, queryset):
         strhtml = '<p><div class="layui-form layui-padding-1"><input type="checkbox" id="AllServer" lay-skin="tag" value="1" title="全部控制"></div></p>'
         strscript='<link rel="stylesheet" href="/static/general/layui/css/layui.css"><script src="/static/general/layui/layui.js"></script><script type="text/javascript">var IntScrcpyArray = [];'
         for obj in queryset:
            query_params =f"?config=%7B%22audio%22%3A%20false%2C%20%22control%22%3A%20true%2C%20%22video%5Fcodec%22%3A%20%22h264%22%2C%20%22audio%5Fcodec%22%3A%20%22aac%22%2C%20%22cleanup%22%3A%20false%2C%20%22video%5Fbit%5Frate%22%3A%20150000%2C%20%22max%5Fsize%22%3A%20160%2C%22tunnel%5Fforward%22%3A%20true%2C%22stay%5Fawake%22%3A%20true%2C%20%22max%5Ffps%22%3A%2010%2C%22lock%5Fvideo%5Forientation%22%3A%200%7D"
            mobile_screen_url = reverse("mobile-listscreen", kwargs={"device_id": obj.device_id, "version": "v1"})
            if self.devices_dict.get(obj.device_id, {}).get('online'):
                strscript=strscript+'IntScrcpyArray.push("Screen_'+f"{obj.id}"+'");'
                strhtml = strhtml + '<iframe style="border: 1px solid #cccccc;margin-left: 5px;" width="130" height="220" id="Screen_'+f"{obj.id}"+'" src="'+mobile_screen_url+query_params+'"></iframe>'
            pass
         strscript=strscript+"function showView(title,src){layer.open({ type: 2,id: 'showView',title: title,maxmin: true,shadeClose: true,area : ['336px' , '720px'],content:src,success: function(layero, index, that){layer.iframeAuto(index);that.offset();}});}"
         strscript=strscript+'function Sendcall(SendData,canvasView,pid){var checkbox = document.getElementById("AllServer");if (checkbox.checked) {for (var i in IntScrcpyArray) {document.getElementById(IntScrcpyArray[i]).contentWindow.AllSend(SendData,canvasView,pid);} } }</script>'
            # mobile_screen_url = reverse("mobile-screen", kwargs={"device_id": obj.device_id, "version": "v1"})
         return HttpResponse(strhtml+strscript)

        # response = HttpResponse(content_type="application/json")
        # serializers.serialize("json", queryset, stream=response)
        # return response
    AllScreen.short_description = '批量投屏'
    AllScreen.style='background-color: #06a17e;color: #fafafa;border-color: #06a17e;'


    def get_fields(self, request, obj=None):
        fields = super().get_fields(request, obj)
        if not request.user.is_superuser and 'user' in fields:
            fields.remove('user')
        return fields

    def get_queryset(self, request):
        queryset = super().get_queryset(request)
        if request.user.is_superuser:
            return queryset
        else:
            current_time = time.strftime('%Y-%m-%d', time.localtime(time.time()))
            print(current_time)
            querysetone =  queryset.filter( stop_time__gte = current_time)
            return querysetone.filter(user=request.user)

    def disconnect(self, request, queryset):
        for obj in queryset:
            adb.AdbDevice.disconnect(obj.device_id)
    disconnect.short_description = '断开'
    def tcpip5555(self, request, queryset):
        for obj in queryset:
            adb.AdbDevice.tcpip(obj.device_id) 
    tcpip5555.short_description = '开启WIFI模式'
    def get_readonly_fields(self, request, obj=None):
        if obj:
            return ['config', 'device_id', 'updated_time', 'created_time']
        else:
            return ['config', 'updated_time', 'created_time']

    def has_add_permission(self, request):
        return False
    
    def recorder(self, obj):
        if json.loads(obj.config).get('recorder_enable'):
            return '🟢'
        else:
            return '🔴'
    recorder.short_description = '开启录屏'

    def online(self, obj):
        if self.devices_dict.get(obj.device_id, {}).get('online'):
            return '🟢'
        else:
            return '🔴'
    online.short_description = '设备状态'

    def screen(self, obj):
        if self.devices_dict.get(obj.device_id, {}).get('online'):
            query_params = f"?config={quote(obj.config)}"
            mobile_screen_url = reverse("mobile-screen", kwargs={"device_id": obj.device_id, "version": "v1"})
            return mark_safe(f'<a href="{mobile_screen_url}{query_params}" target="_blank">访问</a>')
    screen.short_description = '访问屏幕'

    def filemanager(self, obj):
        if self.devices_dict.get(obj.device_id, {}).get('online'):
            mobile_filemanager_url = reverse("mobile-filemanager", kwargs={"device_id": obj.device_id, "version": "v1"})
            return mark_safe(f'<a href="{mobile_filemanager_url}" target="_blank">访问</a>')
    filemanager.short_description = '文件管理'

    def changelist_view(self, request, extra_context=None):
        userauto = request.user.is_superuser
        if userauto:
            self.actions.append("Allauth")
            print(f"-------------{request.user}----------------------")
            pass
        self.devices_dict = adb.AdbDevice.list(slug=True)
        models.Mobile.objects.bulk_create([models.Mobile(device_id=v['device_id'], device_type=v['marketname'])
                                           for v in self.devices_dict.values()], ignore_conflicts=True)
        return super().changelist_view(request, extra_context)
    def save_model(self, request, obj, form, change):
        obj.config = form.cleaned_data['config']
        obj.save()
# @admin.register(models.Picture)
# class PictureAdmin(ExportActionMixin, admin.ModelAdmin):
#     list_per_page = 20
#     show_full_result_count = True
#     search_fields = ['device_id']
#     list_filter = ['device_id', 'created_time']
#     list_display = ['img', 'name', 'device_id', 'download', 'created_time']

#     def download(self, obj):
#         download_url = obj.picture.url
#         return mark_safe(f'<a href="{download_url}" download="{obj.device_id}.jpg">访问</a>')
#     download.short_description = '下载'

# @admin.register(models.Video)
# class VideoAdmin(ExportActionMixin, admin.ModelAdmin):
#     list_per_page = 20
#     show_full_result_count = True
#     search_fields = ['device_id']
#     list_filter = ['device_id', 'format', 'start_time', 'finish_time']
#     list_display = ['video_id', 'format', 'device_id', 'name', 'duration', 'size', 'video_play', 'start_time', 'finish_time']

#     def get_readonly_fields(self, request, obj=None):
#         if obj:
#             return ['video_id', 'device_id', 'format', 'start_time', 'finish_time', 'config', 'duration']
#         else:
#             return []

#     def delete_queryset(self, request: HttpRequest, queryset: QuerySet[Any]) -> None:
#         for obj in queryset:
#             video_path = os.path.join(MEDIA_ROOT, 'video', f'{obj.video_id}.{obj.format}')
#             try:
#                 os.remove(video_path)
#             except:
#                 pass
#         return super().delete_queryset(request, queryset)
    
#     def delete_model(self, request: HttpRequest, obj: Any) -> None:
#         video_path = os.path.join(MEDIA_ROOT, 'video', f'{obj.video_id}.{obj.format}')
#         try:
#             os.remove(video_path)
#         except:
#             pass
#         return super().delete_model(request, obj)

#     def download(self, obj):
#         download_url = f'/media/video/{obj.video_id}.{obj.format}'
#         download_name = f'{obj.video_id}.{obj.format}'
#         return mark_safe(f'<a href="{download_url}" target="_blank" download="{download_name}">访问</a>')
#     download.short_description = '下载'

#     def video_play(self, obj):
#         filename = f"{obj.video_id}.{obj.format}"
#         video_play_url = reverse("asynch:video-play") + f"?filename={filename}"
#         return mark_safe(f'<a href="{video_play_url}" target="_blank">访问</a>')
#     video_play.short_description = '播放/下载'


# @admin.register(models.Picture)
# class PictureAdmin(ExportActionMixin, admin.ModelAdmin):
#     list_per_page = 20
#     show_full_result_count = True
#     search_fields = ['device_id']
#     list_filter = ['device_id', 'created_time']
#     list_display = ['img', 'name', 'device_id', 'download', 'created_time']

#     def download(self, obj):
#         download_url = obj.picture.url
#         return mark_safe(f'<a href="{download_url}" download="{obj.device_id}.jpg">访问</a>')
#     download.short_description = '下载'

#     def img(self, obj):
#         return mark_safe(f'<img src="{obj.picture.url}" height="100" width="100">')
#     img.short_description = '截图'

#     def delete_queryset(self, request: HttpRequest, queryset: QuerySet[Any]) -> None:
#         for obj in queryset:
#             picture_path = os.path.join(MEDIA_ROOT, 'picture', obj.picture.url.split('/')[-1])
#             try:
#                 os.remove(picture_path)
#             except:
#                 pass
#         return super().delete_queryset(request, queryset)
    
#     def delete_model(self, request: HttpRequest, obj: Any) -> None:
#         picture_path = os.path.join(MEDIA_ROOT, 'picture', obj.picture.url.split('/')[-1])
#         try:
#             os.remove(picture_path)
#         except:
#             pass
#         return super().delete_model(request, obj)
