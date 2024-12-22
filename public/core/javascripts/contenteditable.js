function focus_td(td, set_cursor_at_the_end=true) {
    $(td).focus();
    $(td).find('i').remove();
    $(td).attr('data-original-value', $(td).text());

    // select all text inside a contenteditable td
    if (set_cursor_at_the_end) {
      let range = document.createRange(); // Create a new range
      let selection = window.getSelection(); // Get the selection object
      range.selectNodeContents($(td)[0]); // Select all contents of the element
      range.collapse(false); // Collapse the range to this end
      selection.removeAllRanges(); // Remove any existing selections
      selection.addRange(range); // Add the new range
    }
}

function init_contenteditable(f) {
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

    //
    $('*[contenteditable]').keydown(function(e) {
      if (e.which == 13) {
        // stop event propagation
        //e.stopPropagation();
      }
    });

    // when press escape on a contenteditable td, the content is restored to the original value, quit focos on such a td elemenft too.
    // when press on down arrow, focus the next td element right below with the same value in the data-field attribute
    // when press on up arrow, focus the previous td element right above with the same value in the data-field attribute
    // when press on the right arrow, focus the next td element right which is contenteditable, skipping the tds in the middle who are not contenteditable
    // when press on the left arrow, focus the next td element left which is contenteditable, skipping the tds in the middle who are not contenteditable
    $('*[contenteditable]').keyup(function(e) {
      function getCaretCharacterOffsetWithin(element) {
        var caretOffset = 0;
        var sel = window.getSelection();
        if (sel.rangeCount > 0) {
          var range = sel.getRangeAt(0);
          var preCaretRange = range.cloneRange();
          preCaretRange.selectNodeContents(element);
          preCaretRange.setEnd(range.endContainer, range.endOffset);

          // Create a temporary div to hold the cloned content
          var tempDiv = document.createElement('div');
          tempDiv.appendChild(preCaretRange.cloneContents());

          // Get the text content of the temporary div
          var textBeforeCursor = tempDiv.innerText || tempDiv.textContent || '';

          // Trim any leading/trailing whitespace
          textBeforeCursor = textBeforeCursor.replace(/\s/g, '');

          caretOffset = textBeforeCursor.length;
        }
        return caretOffset;
      }

      function isCursorAtEnd(element) {
        var caretOffset = getCaretCharacterOffsetWithin(element);
        var textLength = element.textContent.trim().length;
        return caretOffset === textLength;
      }

      function isCursorAtStart(element) {
        var caretOffset = getCaretCharacterOffsetWithin(element);
        return caretOffset === 0;
      }

      // get the id of the lead
      let id = $(this).attr('data-id');
      // get the field name
      let field = $(this).attr('data-field');
      // get the new value
      let value = $(this).text().trim();

      if (e.which == 13) {
        // stop event propagation
        e.stopPropagation();
        this.innerText = value;
        this.focus();
        this.blur();
        // callback function to update the field
        f(id, field, value);
      } else if (e.which == 27) { // escape
        $(this).text($(this).attr('data-original-value'));
        $(this).blur();
      } else if (e.which == 40) { // down arrow
        let field = $(this).attr('data-field');
        let next = $(this).closest('tr').next().find('td[data-field="'+field+'"]');
        if (next.length > 0) {
          // stop event propagation
          e.stopPropagation();
          this.innerText = value;
          this.focus();
          this.blur();
          // callback function to update the field
          f(id, field, value);

          focus_td(next);
        }
      } else if (e.which == 38) { // up arrow
        let field = $(this).attr('data-field');
        let prev = $(this).closest('tr').prev().find('td[data-field="'+field+'"]');
        if (prev.length > 0) {
          // stop event propagation
          e.stopPropagation();
          this.innerText = value;
          this.focus();
          this.blur();
          // callback function to update the field
          f(id, field, value);

          focus_td(prev);
        }
      } else if (e.which == 39) { // right arrow
        if (isCursorAtEnd(this)) {
          let next = $(this).next();
          while (next.length > 0 && !next.is('[contenteditable]')) {
            next = next.next();
          }
          if (next.length > 0) {
            // stop event propagation
            e.stopPropagation();
            this.innerText = value;
            this.focus();
            this.blur();
            // callback function to update the field
            f(id, field, value);

            focus_td(next, false);
          }
        }
      } else if (e.which == 37) { // left arrow
        if (isCursorAtStart(this)) {
          let prev = $(this).prev();
          while (prev.length > 0 && !prev.is('[contenteditable]')) {
            prev = prev.prev();
          }
          if (prev.length > 0) {
            // stop event propagation
            e.stopPropagation();
            this.innerText = value;
            this.focus();
            this.blur();
            // callback function to update the field
            f(id, field, value);

            focus_td(prev, true);
          }
        }
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
