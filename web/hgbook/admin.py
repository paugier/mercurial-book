from django.contrib import admin
from hgbook.comments.models import Comment, Element

class CommentAdmin(admin.ModelAdmin):
    list_display = ['element', 'submitter_name', 'comment', 'reviewed',
                    'hidden', 'date']
    search_fields = ['comment']
    date_hierarchy = 'date'
    list_filter = ['date', 'submitter_name']
    search_fields = ['title', 'submitter_name', 'submitter_url']
    fields = (
        (None, {'fields': ('submitter_name', 'element', 'comment')}),
        ('Review and presentation state',
         {'fields': ('reviewed', 'hidden')}),
        ('Other info', {'fields': ('date', 'submitter_url', 'ip')}),
        )

class ElementAdmin(admin.ModelAdmin):
    search_fields = ['id', 'chapter']
    list_filter = ['chapter', 'title']

admin.site.register(Comment, CommentAdmin)
admin.site.register(Element, ElementAdmin)
