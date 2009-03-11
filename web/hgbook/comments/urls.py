from django.conf.urls.defaults import *

urlpatterns = patterns('',
    (r'chapter/(?P<id>[^/]+)/?$', 'hgbook.comments.views.chapter'),
    (r'chapter/(?P<id>[^/]+)/count/?$', 'hgbook.comments.views.chapter_count'),
    (r'single/(?P<id>[^/]+)/?$', 'hgbook.comments.views.single'),
    (r'submit/(?P<id>[^/]+)/?$', 'hgbook.comments.views.submit')
)
