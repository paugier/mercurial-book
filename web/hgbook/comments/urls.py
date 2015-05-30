from django.conf.urls import url

urlpatterns = [
    url(r'chapter/(?P<id>[^/]+)/?$', 'comments.views.chapter'),
    url(r'chapter/(?P<id>[^/]+)/count/?$', 'comments.views.chapter_count'),
    url(r'single/(?P<id>[^/]+)/?$', 'comments.views.single'),
    url(r'submit/(?P<id>[^/]+)/?$', 'comments.views.submit')
]
