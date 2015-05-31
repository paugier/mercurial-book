import os, sys
import comments.feeds as feeds
import book.views
from django.contrib import admin
from django.conf.urls import include, url
from django.contrib.syndication.views import Feed
from django.views.generic import TemplateView
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
    url(r'^$', TemplateView.as_view(template_name='index.html')),
    url(r'^html/$', book.views.index),
    url(r'^html/(?P<path>.*)$', 'django.views.static.serve',
     {'document_root': os.path.join(settings.BASE_DIR, '..', '..', 'build', 'en', 'html')}),
    url(r'^support/(?P<path>.*)$', 'django.views.static.serve',
     {'document_root': os.path.join(settings.BASE_DIR, '..', 'support')}),

    # Uncomment this for admin:
    url(r'^admin/', include(admin.site.urls)),
]
