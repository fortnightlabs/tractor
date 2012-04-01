;(function($, undefined) {
  $.fn.or = function(el) {
    return (this.length === 0) ? this.add(el) : this;
  };
})(jQuery);
