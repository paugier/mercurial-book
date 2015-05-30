from django.conf.urls import url

urlpatterns = [
    url(r'chapter/(?P<id>[^/]+)/?$', 'hgbook.comments.views.chapter'),
    url(r'chapter/(?P<id>[^/]+)/count/?$', 'hgbook.comments.views.chapter_count'),
    url(r'single/(?P<id>[^/]+)/?$', 'hgbook.comments.views.single'),
    url(r'submit/(?P<id>[^/]+)/?$', 'hgbook.comments.views.submit')
]
