$(function() {
  $('.dropdown-toggle').dropdown();
  $('.alert').alert();

  var enableContacts = function(items) {
    $(items)
      .addClass("badge-success")
      .find('.is-enabled').val('true');
  }
  var disableContacts = function(items) {
    $(items)
      .removeClass("badge-success")
      .find('.is-enabled').val('');
  }

  $('.contacts .badge').on('click', function() {
    $this = $(this);
    $('.nav-pills li').removeClass('active');
    $('#filter_custom').closest('li').addClass('active');
    if ($this.hasClass("badge-success")) {
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

  $('#filter_custom').on('click', function() {
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

  $('#send_email').on('click', function(event) {
    event.preventDefault();
    emails = [];
    $('.contacts .badge').each(function(i, item) {
      $item = $(item);
      if ($item.find('.is-enabled').val() == 'true') {
        email = $.trim($item.find('.email').val());
        if (email != "")
          emails.push(email);
      }
    });
    window.location = "mailto:" + emails.join(', ') + "?body=" + encodeURIComponent($('#contact_message').val());
  });
  
});
