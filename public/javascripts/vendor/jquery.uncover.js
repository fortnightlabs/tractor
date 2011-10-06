(function($, window, undefined) {
  var $window = $(window);
  $.uncover = function(item, options) {
    return $window.uncover(item, options);
  };

  $.fn.uncover = function(item, options) {
    uncover(this, item, options);
    return this;
  };

  function uncover(parent, child, options) {
    options = options || {};
    // make sure child is scrolled to in the parent
    var paddingTop = options.paddingTop || 0,
        paddingBottom = options.paddingBottom || 0,
        ct = child.offset().top,
        pt = (parent.offset() ? parent.offset().top : parent.scrollTop()) + paddingTop,
        up = ct - pt,
        down = ct + child.innerHeight()-1 - (pt + parent.height() - paddingTop - paddingBottom),
        delta = up < 0 ? up : (down > 0 ? down : 0);
    options = options || {};

    if (delta === 0 || up < 0 && down > 0)
      return; // it's visible

    if (options.before) options.before();
    parent.scrollTop(parent.scrollTop() + delta);
    if (options.after) options.after();
  }
})(jQuery, window);
