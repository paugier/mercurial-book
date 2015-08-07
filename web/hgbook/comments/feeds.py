from django.core.exceptions import ObjectDoesNotExist
from django.utils.feedgenerator import Atom1Feed
from django.contrib.syndication.views import Feed
from comments.models import Comment, Element

class MyAtomFeed(Atom1Feed):
    title_type = u'html'
    
class Comments(Feed):
    feed_type = MyAtomFeed
    title = 'Mercurial - The Definitive Guide: recent comments'
    subtitle = ('Recent comments on the text of &#8220;Mercurial: The '
                'Definitive Guide&#8221;, from our readers')
    link = '/feeds/comments/'
    author_name = 'Our readers'

    def feedfilter(self, queryset):
        return queryset.order_by('-date')[:20]

    def items(self):
        return self.feedfilter(Comment.objects)

    def item_author_name(self, obj):
        return obj.submitter_name

    def item_pubdate(self, obj):
        return obj.date

    def get_object(self, request, url):
        if len(url) == 0: #Full book
            return self.items()
        return self.feedfilter(Comment.objects.filter(element__chapter=url,
                                                      hidden=False))
