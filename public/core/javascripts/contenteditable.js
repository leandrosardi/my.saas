function focus_td(td) {
    $(td).focus();
    $(td).find('i').remove();
    $(td).attr('data-original-value', $(td).text());
}

function init_contenteditable(url) {
    // add an i element the top-right corner of content editable tds
    $('*[contenteditable]').append('<i class="icon-pencil" style="padding-left:5px;opacity:0.25;"></i>');

    // when the content is changed, the i element is removed, and store original value on data-original-value
    $('*[contenteditable]').on('click', function() {
      focus_td(this);
    });

    // the the contenteditable lost focus, the i element is added again only if it doesn't exist
    $('*[contenteditable]').on('blur', function() {
      i = $(this).find('i');
      if (i.length == 0) {
        $(this).append('<i class="icon-pencil" style="padding-left:5px;opacity:0.25;"></i>');
      }
    });
    
    // when press escape on a contenteditable td, the content is restored to the original value, quit focos on such a td elemenft too.
    // when press on down arrow, focus the next td element right below with the same value in the data-field attribute
    // when press on up arrow, focus the previous td element right above with the same value in the data-field attribute
    // when press on the right arrow, focus the next td element right which is contenteditable, skipping the tds in the middle who are not contenteditable
    // when press on the left arrow, focus the next td element left which is contenteditable, skipping the tds in the middle who are not contenteditable
    $('*[contenteditable]').keyup(function(e) {
      if (e.which == 27) {
        $(this).text($(this).attr('data-original-value'));
        $(this).blur();
      } else if (e.which == 40) {
        let field = $(this).attr('data-field');
        let next = $(this).closest('tr').next().find('td[data-field="'+field+'"]');
        if (next.length > 0) {
          focus_td(next);
        }
      } else if (e.which == 38) {
        let field = $(this).attr('data-field');
        let prev = $(this).closest('tr').prev().find('td[data-field="'+field+'"]');
        if (prev.length > 0) {
          focus_td(prev);
        }
      } else if (e.which == 39) {
        // focus the next td element left which is contenteditable, skipping the tds in the middle who are not contenteditable
        let next = $(this).next();
        while (next.length > 0 && !next.is('[contenteditable]')) {
          next = next.next();
        } 
        if (next.length > 0) {
          focus_td(next);
        }
      } else if (e.which == 37) {
        let prev = $(this).prev();
        while (prev.length > 0 && !prev.is('[contenteditable]')) {
          prev = prev.prev();
        }
        if (prev.length > 0) {
          focus_td(prev);
        }
      }
    });

    // when press enter on a contenteditable td, call ajax to update the field
    $('*[contenteditable]').keypress(function(e) {
      var td = this;
      if (e.which == 13) {
        // get the id of the lead
        let id = $(this).attr('data-id');
        // get the field name
        let field = $(this).attr('data-field');
        // get the new value
        let value = $(this).text();
        // call ajax to update the field
        $.ajax({
          url: url,
          type: 'POST',
          data: {
            id: id,
            field: field,
            value: value
          },
          success: function(data) {
            // get the json response
            let response = JSON.parse(data);
            if (response.status == 'success') {
              // update the field with the new value
              $(td).text(value);
              $(td).blur();
            } else {
              alert('An error occured while updating the field:' + field + '. Error: ' + response.status);
            }
          },
          error: function(data) {
            alert('Unknown error occured while updating the field:' + field + '.');
          },
        });
      }
    });
};
  
function init_search(url=null) {
    if (url == null) {
      url = window.location.href.split('?')[0]
    }
    // when click on #search, redirect to /leads?q=...
    // the value of q is in the input #q
    // encode the value of q
    $("#search").click(function() {
      // get the value of the input #q
      let q = $('#q').val();
      // reload the same page (I don't know its URL a priori) with the q parameter
      window.location.href = url + '?q=' + encodeURIComponent(q);
    });

    // when press enter on #q, redirect to /leads?q=...
    // the value of q is in the input #q
    // encode the value of q
    $("#q").keypress(function(e) {
      if (e.which == 13) {
        // get the value of the input #q
        let q = $('#q').val();
        // redirect to /leads?q=...
        window.location.href = url + '?q=' + encodeURIComponent(q);
      }
    });
};

function init_command_inputs() {
    // cancel any forther event when click on input.command
    $('.command').click(function() {
      return false;
    })
};