from django.db import models
import sha

mutable = True

class Element(models.Model):
    id = models.CharField('ID attribute', max_length=64, editable=False,
                          primary_key=True)
    chapter = models.CharField('Chapter ID', max_length=100, editable=False,
                               db_index=True)
    title = models.CharField('Section title', max_length=256, editable=False)

    def __unicode__(self):
        return self.id
    
class Comment(models.Model):
    element = models.ForeignKey(Element,
        help_text='ID of paragraph that was commented on')
    comment = models.TextField(editable=mutable,
        help_text='Text of submitted comment (please do not modify)')
    submitter_name = models.CharField('Submitter', max_length=64,
        help_text='Self-reported name of submitter (may be bogus)')
    submitter_url = models.URLField('URL', blank=True, editable=mutable,
        help_text='Self-reported URL of submitter (may be empty or bogus)')
    ip = models.IPAddressField('IP address', editable=mutable,
        help_text='IP address from which comment was submitted')
    date = models.DateTimeField('date submitted', auto_now=True,
                                auto_now_add=True)
    reviewed = models.BooleanField(default=False, db_index=True,
        help_text='Has this comment been reviewed by an author?')
    hidden = models.BooleanField(default=False, db_index=True,
        help_text='Has this comment been hidden from public display?')

    def __unicode__(self):
        return self.comment[:32]

    def get_absolute_url(self):
        s = sha.new()
        s.update(repr(self.comment))
        s.update(repr(self.submitter_name))
        s.update(str(self.date))
        return '/read/%s.html#%s?comment=%s&uuid=%s' % (
            self.element.chapter, self.element.id, self.id, s.hexdigest()[:20]
            )
