import os, sys
from django.conf.urls.defaults import *
import hgbook.comments.feeds as feeds
from django.contrib import admin

admin.autodiscover()

feeds = {
    'comments': feeds.Comments,
    }

urlpatterns = patterns('',
    (r'^comments/', include('hgbook.comments.urls')),

    (r'^feeds/(?P<url>.*)/$', 'django.contrib.syndication.views.feed',
     {'feed_dict': feeds}),          

    # Only uncomment this for local testing without Apache.
     (r'^html/(?P<path>.*)$', 'django.views.static.serve',
     {'document_root': os.path.realpath(os.path.dirname(
        sys.modules[__name__].__file__) + '/../html')}),
     (r'^support/(?P<path>.*)$', 'django.views.static.serve',
     {'document_root': os.path.realpath(os.path.dirname(
        sys.modules[__name__].__file__) + '/../support')}),

    # Uncomment this for admin:
    (r'^admin/(.*)', admin.site.root),
)
