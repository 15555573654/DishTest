from django.urls import path
from . import views
 
urlpatterns = [
    path('hello/', views.hello, name='hello'),
    # 添加更多的路由
]