$(function() {
  $('.dropdown-toggle').dropdown();

  var enableContacts = function(items) {
    $(items)
      .addClass("badge-info")
      .find('.is-enabled').val('true');
  }
  var disableContacts = function(items) {
    $(items)
      .removeClass("badge-info")
      .find('.is-enabled').val('');
  }

  $('.contacts .badge').on('click', function() {
    $this = $(this);
    $('.nav-pills li').removeClass('active');
    $('#filter_custom').closest('li').addClass('active');
    if ($this.hasClass("badge-info")) {
      disableContacts($this);
    } else {
      enableContacts($this);
    }
  }).tooltip({ delay: { show: 500, hide: 80 } });

  $('#filter_all').on('click', function() {
    enableContacts($('.contacts .badge'));
    $('.nav-pills li').removeClass('active');
    $(this).closest('li').addClass('active');
  });

  $('#filter_none').on('click', function() {
    disableContacts($('.contacts .badge'));
    $('.nav-pills li').removeClass('active');
    $(this).closest('li').addClass('active');
  });

  $('#filter_district ul a').on('click', function() {
    disableContacts($('.contacts .badge'));
    enableContacts($('.contacts .badge[data-district=' + $(this).text() + ']'));
    $('.nav-pills li').removeClass('active');
    $(this).closest('li').addClass('active');
    $('#filter_district').addClass('active');
  });
  
});
