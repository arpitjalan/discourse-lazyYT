/**
  Apply lazyYT when the app boots
**/
export default {
  name: "apply-lazyYT",
  initialize: function(container) {
    var applyLazyYT = function($elem) {
      $('.lazyYT', $elem).lazyYT();
    };

    var decorate = function(klass, evt) {
      klass.reopen({
        applyLazyYT: function($elem) {
          applyLazyYT($elem);
        }.on(evt)
      });
    };

    decorate(Discourse.PostView, 'postViewInserted');
    decorate(container.lookupFactory('view:composer'), 'previewRefreshed');
    decorate(container.lookupFactory('view:embedded-post'), 'previewRefreshed');
    decorate(container.lookupFactory('view:user-stream'), 'didInsertElement');
  }
};
