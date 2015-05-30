import os, sys
import comments.feeds as feeds
from django.contrib import admin
from django.conf.urls import include, url
from django.contrib.syndication.views import Feed
import settings

admin.autodiscover()

feeds = {
    'comments': feeds.Comments,
    }

urlpatterns = [
    url(r'^comments/', include('comments.urls')),

    url(r'^feeds/(?P<url>.*)/$', Feed(),
     {'feed_dict': feeds}),          

    # Only uncomment this for local testing without Apache.
    url(r'^html/(?P<path>.*)$', 'django.views.static.serve',
     {'document_root': os.path.join(settings.BASE_DIR, '..', '..', 'build', 'en', 'html')}),
    url(r'^support/(?P<path>.*)$', 'django.views.static.serve',
     {'document_root': os.path.realpath(os.path.dirname(
        sys.modules[__name__].__file__) + '/../support')}),

    # Uncomment this for admin:
    url(r'^admin/', include(admin.site.urls)),
]
