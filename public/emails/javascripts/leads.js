  // enable/disable the add button depending on the value of the textfield
  function enable_add_button(id_lead) {
    // find the ul with this data-id-lead='id_lead'
    let ul = document.querySelector('ul.ul-export-lists[data-id-lead="'+id_lead+'"]');
    // find the button inside the ul
    let button = ul.querySelector('button.btn-create-export-list');
    // find the textfield inside the ul
    let textfield = ul.querySelector('input.input-export-lists');
    // if the textfield is empty, disable the button
    if (textfield.value.trim() == '') {
      // disable the button
      button.disabled = true;
      // remove any span just below the textfield
      let span = ul.querySelector('span');
      if (span) {
        // remove span
        span.remove();
      }
    } else {
      // if the name already exists in the list, disabe the button
      if (ul.querySelector('li[data-name="'+textfield.value.trim()+'"]')) {
        // disable the button
        button.disabled = true;
        // show a red text 'Name already exists' just below the textfield
        textfield.parentNode.insertBefore(document.createElement('span'), textfield.nextSibling).innerHTML = 'Name already exists';
      } else {
        // enable the button
        button.disabled = false;
        // remove any span just below the textfield
        let span = ul.querySelector('span');
        if (span) {
          // remove span
          span.remove();
        }
      }
    }
  }

  // remove an export list
  function remove_export_list(id_lead, id_export) {
    // find the il with this data-id-lead='id_lead' and data-id-export='id_export'
    let li = document.querySelector('li[data-id-lead="'+id_lead+'"][data-id-export-list="'+id_export+'"]');
    // delete the element
    li.remove();
  }

  // receive a hash descriptor of the export related with the lead { id:, filename:, belonging: }
  function add_export_list(id_lead, h, opacity='1.0') {
    // find the div
    let div = document.querySelector('div.div-export-lists[data-id-lead="'+id_lead+'"]');
    // remove '<i>' element with innert text 'No export lists found' from the div content
    $('i:contains("No export lists found")').remove();
    // create the li element, with hand cursor
    let li = document.createElement('li');
    li.setAttribute('data-id-export-list', h.id);
    li.setAttribute('data-id-lead', id_lead);
    li.setAttribute('data-name', h.filename);
    li.setAttribute('data-belonging', h.belonging.toString());
    li.style.cursor = 'pointer';
    li.style.opacity = opacity;
    // create an icon-ok element, with style green text color
    let icon = document.createElement('i');
    icon.setAttribute('data-id-export-list', h.id);
    icon.setAttribute('data-id-lead', id_lead);
    if ( h.belonging ) { 
      icon.setAttribute('style', 'color: green');
      icon.setAttribute('class', 'icon-check');
    } else {
      icon.setAttribute('style', 'color: gray');
      icon.setAttribute('class', 'icon-check-empty');
    }
    // add the icon and the name of the list to the anchor
    li.appendChild(icon);
    li.appendChild(document.createTextNode(' '));
    li.appendChild(document.createTextNode(h.filename));
    // if the export is deleted, then add a "deleted" label
    if (h.deleted === true) {
      li.appendChild(document.createTextNode(' (deleted)'));
    }
    // add the li to the ul
    $(div).append(li);
    // on click on the li, call ajax to add/remove the lead from/to the export list
    li.addEventListener('click', function(e) {
      // decide the access point to call
      if ($(li).attr('data-belonging') == 'true') {
        // remove from the list
        access_point = 'remove_lead_from_export_list';
      } else {
        // add to the list
        access_point = 'add_lead_to_export_list';
      }
      // set the li with 50% opacity, to show that it is being processed
      li.style.opacity = '0.5';
      // call the ajax
      $.ajax({
        url: '/ajax/leads/'+access_point+'.json',
        type: 'POST',
        data: {
          id_lead: id_lead,
          id_export: h.id
        },
        success: function(data) {
          // get the json response
          let response = JSON.parse(data);
          // if the response is ok, update the icon
          if (response.status == 'success') {
            // the titlt is updated immedaitelly after the ajax call. don't wait for response because of an ux matter. 
            // update the li opacity, to show that is has been processed successfully
            li.style.opacity = '1.0';
            // update the credits in the header
            i2p_update_header('leads');
          } else {
            if ( response.status =~ /No Credits/ ) {
              window.location.replace('/plans');
            } else {
              alert('An error occured while updating the list:' + h.filename + '. Error: ' + response.status);
            }
          }
        },
        error: function(data) {
          alert('Unknown error occured while updating the list:' + h.filename + '.');
        },
      });
      // better user experience: unlock data immediatelly. don't wait until the ajax success
      // unlock contact information
      unlock_data(id_lead);
      // find the icon about this export list and this lead
      let icon = document.querySelector('i[data-id-export-list="'+h.id+'"][data-id-lead="'+id_lead+'"]');
      // if the icon is green, change it to gray
      if ($(li).attr('data-belonging') == 'true') {
        icon.setAttribute('style', 'color: gray');
        icon.setAttribute('class', 'icon-check-empty');
        li.setAttribute('data-belonging', 'false');
      } else {
        icon.setAttribute('style', 'color: green');
        icon.setAttribute('class', 'icon-check');
        li.setAttribute('data-belonging', 'true');
      }
      // JavaScript, stop additional event listeners
      // reference: https://www.w3schools.com/jsref/event_stopimmediatepropagation.asp
      e.stopImmediatePropagation();
    });
  }

function setup_remove_data() {
    $('.btn-remove-data').click(function() {
      // get the id_lead
      let id_data = $(this).attr('data-id-data');
      let span = document.querySelector('span.contact-info-item[data-id-data="'+id_data+'"]');
      // show adding legend
      span.innerHTML = 'removing data...<br/>';      
      // ajax call
      $.ajax({
        url: '/ajax/leads/remove_data.json',
        type: 'POST',
        data: { id_data: id_data },
        success: function(data) {
          // get the json response
          let response = JSON.parse(data);
          if (response.status == 'success') {
            span.remove();
          } else {
            alert(response.status);
            alert('An error occured trying to remove data to the lead. Error: ' + response.status);
          }
        }, error: function(data) {
          // get the json response
          let response = JSON.parse(data);
          alert('Unknown error occured trying to remove data to the lead.');
        }
      });      
    });
  }

  function setup_remove_reminder() {
    $('.btn-remove-reminder').click(function() {
      // get the id_lead
      let id_reminder = $(this).attr('data-id-reminder');
      let span = document.querySelector('span.reminders-item[data-id-reminder="'+id_reminder+'"]');
      // show adding legend
      span.innerHTML = 'removing reminder...<br/>';      
      // ajax call
      $.ajax({
        url: '/ajax/leads/remove_reminder.json',
        type: 'POST',
        data: { id_reminder: id_reminder },
        success: function(data) {
          // get the json response
          let response = JSON.parse(data);
          if (response.status == 'success') {
            span.remove();
          } else {
            alert(response.status);
            alert('An error occured trying to remove reminder from the lead. Error: ' + response.status);
          }
        }, error: function(data) {
          // get the json response
          let response = JSON.parse(data);
          alert('Unknown error occured trying to remove reminder from the lead.');
        }
      });      
    });
  }

  function setup_done_reminder() {
    $('.btn-done-reminder').click(function() {
      // get the id_lead
      let id_reminder = $(this).attr('data-id-reminder');
      let span = this;
      // show adding legend
      span.style.color = 'gray';   
      span.setAttribute('class', '');
      if ( span.style.textDecoration != 'line-through' ) {
        $.ajax({
          url: '/ajax/leads/mark_reminder_as_done.json',
          type: 'POST',
          data: { id_reminder: id_reminder },
          success: function(data) {
            // get the json response
            let response = JSON.parse(data);
            if (response.status == 'success') {
              span.style.color = 'black';      
              span.style.textDecoration = 'line-through';
            } else {
              alert(response.status);
              alert('An error occured trying to mark reminder as done. Error: ' + response.status);
            }
          }, error: function(data) {
            // get the json response
            let response = JSON.parse(data);
            alert('Unknown error occured trying to mark reminder as done.');
          }
        });
      } else {
        $.ajax({
          url: '/ajax/leads/mark_reminder_as_pending.json',
          type: 'POST',
          data: { id_reminder: id_reminder },
          success: function(data) {
            // get the json response
            let response = JSON.parse(data);
            if (response.status == 'success') {
              span.style.color = 'black';      
              span.style.textDecoration = 'none';
            } else {
              alert(response.status);
              alert('An error occured trying to mark reminder as pending. Error: ' + response.status);
            }
          }, error: function(data) {
            // get the json response
            let response = JSON.parse(data);
            alert('Unknown error occured trying to mark reminder as pending.');
          }
        });
      }
    });
  }

  function unlock_data(id_lead) {
    // find the div
    let div = document.querySelector('div.contact-info[data-id-lead="'+id_lead+'"]');
    let div_reminders = $('div.reminders[data-id-lead="'+id_lead+'"]');
    // remove everything inside the div
    div.innerHTML = '';
    div_reminders.html('');
    // add loading legend
    i = document.createElement('i');
    i.innerHTML = 'Loading data...';
    div.appendChild(i);
    // call the ajax
    $.ajax({
      url: '/ajax/leads/get_lead_data.json',
      type: 'POST',
      data: {
        id_lead: id_lead
      },
      success: function(data) {
        // get the json response
        let response = JSON.parse(data);
        // if the response is ok, update the div
        if (response.status == 'success') {
          // change export button .btn-export-lists color and text
          // remove class btn-green
          // remove class btn-blue
          // remove class btn-gray
          // add class btn-blue or btn-gray
          // set 'Exported' as inner text in the span with class .caption inside such a buttton
          let button = document.querySelector('button.btn-export-lists[data-id-lead="'+id_lead+'"]');
          button.classList.remove('btn-green');
          button.classList.remove('btn-blue');
          button.classList.remove('btn-gray');
          button.classList.add('btn-'+response.button_color);
          button.querySelector('span.caption').innerHTML = response.button_text;
          // remove the loading legend
          div.innerHTML = '';
          // draw the reminders
          response.reminders.forEach(function(h) {
            // create the child span
            let span = document.createElement('span');
            span.setAttribute('data-id-reminder', h.id);
            // set remove button
            let remove = document.createElement('button');
            remove.setAttribute('class', 'btn btn-link btn-remove-reminder');
            remove.setAttribute('data-id-lead', id_lead);
            remove.setAttribute('data-id-reminder', h.id);
            $(remove).html('<i class="icon-trash"></i>');
            // set done or undone icon
            let done = document.createElement('button');
            let done_class = '';
            // set icon
            let icon = document.createElement('i');
            let a = document.createElement('a');
            icon.setAttribute('class', 'icon-calendar');
            icon.setAttribute('title', 'Reminder');
            // build the span with the reminder
            span.setAttribute('class', 'reminders-item');
            span.appendChild(remove);
            span.appendChild(icon);
            span2 = document.createElement('span');
            span2.innerText = ' ' + h.expiration_time.toString().slice(0, 10) + ' ';
            span2.style.fontWeight = 'bold';
            span.appendChild(span2);
            span3 = document.createElement('span');
            span3.setAttribute('class', 'btn-done-reminder')
            span3.setAttribute('data-id-reminder', h.id);
            span3.style.cursor='pointer';
            span3.innerHTML = h.description + '<br/>';
            if (h.done == true) {
              span3.style.textDecoration = 'line-through';
            }
            span.appendChild(span3);
            div_reminders.append(span);
          });
          // draw the datas
          response.datas.forEach(function(h) {
            // create the child span
            let span = document.createElement('span');
            span.setAttribute('data-id-data', h.id);
            // set remove button
            let remove = document.createElement('button');
            remove.setAttribute('class', 'btn btn-link btn-remove-data');
            remove.setAttribute('data-id-lead', id_lead);
            remove.setAttribute('data-id-data', h.id);
            $(remove).html('<i class="icon-trash"></i>');
            // create icon with icon-envelope or icon-phone, depending on the type
            // create span with class email or phone, depending on the type
            // create anchor with href mailto or tel, depending on the type
            let icon = document.createElement('i');
            let a = document.createElement('a');
            if ( h.type == 20 ) {
              icon.setAttribute('class', 'icon-envelope');
              span.setAttribute('class', 'contact-info-item email');
              a.setAttribute('href', 'mailto:'+h.value);
            } else if ( h.type == 10 ) {
              icon.setAttribute('class', 'icon-phone');
              span.setAttribute('class', 'contact-info-item phone');
              a.setAttribute('href', 'tel:'+h.value);
            } else if ( h.type == 90 ) {
              icon.setAttribute('class', 'icon-linkedin');
              span.setAttribute('class', 'contact-info-item linkedin');
              a.setAttribute('href', h.value);
              a.setAttribute('target', '_window');
            } else if ( h.type == 80 ) {
              icon.setAttribute('class', 'icon-facebook');
              span.setAttribute('class', 'contact-info-item facebook');
              a.setAttribute('href', h.value);
              a.setAttribute('target', '_window');
            }
            // set title
            div.title = h.value;
            // set overflow hidden for the div
            div.style.overflow = 'hidden';
            a.style.overflow = 'hidden';
            span.style.overflow = 'hidden';
            // set text-overflow hidden for the div
            div.style.textOverflow = 'ellipsis';
            a.style.textOverflow = 'ellipsis';
            span.style.textOverflow = 'ellipsis';
            // draw
            a.appendChild(document.createTextNode(h.value));
            span.appendChild(remove);
            span.appendChild(icon);
            span.appendChild(document.createTextNode(' '));
            span.appendChild(a);
            span.appendChild(document.createElement('br'));
            div.appendChild(span);
            // setup all .btn-remove-data to remove data
            setup_remove_data();
            // setup all .btn-remove-reminder to remove reminder
            setup_remove_reminder();
            setup_done_reminder();
          });
        } else {
          alert('An error occured while unlocking lead data. Error: ' + response.status);
        }
      },
      error: function(data) {
        alert('Unknown error occured while unlocking lead data.');
      },
    });
  }

function init_lead_data() {
    // hide .add-data-div
    $('.add-data-div').hide();
    // show .add-data-div when .add-data is clicked
    $('.add-data').click(function() {
        let id_lead = $(this).attr('data-id-lead');
        let input_type = document.querySelector('input.add-data-type[data-id-lead="'+id_lead+'"]');
        let div = document.querySelector('div.add-data-div[data-id-lead="'+id_lead+'"]');
        input_type.value = $(this).attr('data-type'); 
        $(div).show();
        $(div).find('input').focus();
    });
    // hide .add-data-div when .add-data-cancel is clicked
    $('.add-data-cancel').click(function() {
        let id_lead = $(this).attr('data-id-lead');
        let div = document.querySelector('div.add-data-div[data-id-lead="'+id_lead+'"]');
        $(div).hide();
      });
  
      // ajax call to /leads/ajax/add_data.json when the user clicks on .add-data-submit
      $('.add-data-submit').click(function () {
        let id_lead = $(this).attr('data-id-lead');
        let input_value = document.querySelector('input.add-data-value[data-id-lead="'+id_lead+'"]'); 
        let input_type = document.querySelector('input.add-data-type[data-id-lead="'+id_lead+'"]'); 
        let div = document.querySelector('div.add-data-div[data-id-lead="'+id_lead+'"]');
        let div_data = document.querySelector('div.contact-info[data-id-lead="'+id_lead+'"]');
        // hide form
        $(div).hide();
        // show adding legend
        div_data.innerHTML = 'adding data...';      
        // ajax call
        $.ajax({
          url: '/ajax/leads/add_data.json',
          type: 'POST',
          data: { id_lead: id_lead, value: input_value.value, type: input_type.value },
          success: function(data) {
            // get the json response
            let response = JSON.parse(data);
            if (response.status == 'success') {
              unlock_data(id_lead);
            } else {
              alert(response.status);
              alert('An error occured trying to add data to the lead. Error: ' + response.status);
            }
          }, error: function(data) {
            // get the json response
            let response = JSON.parse(data);
            alert('Unknown error occured trying to add data to the lead.');
          }
        });      
      });
      // fire .add-data-cancel when :esc is pressed on .add-data-value
      // fire .add-data-submit when :enter is pressed on .add-data-value
      $('.add-data-value').keyup(function(e) {
        let id_lead = $(this).attr('data-id-lead');      
        if (e.keyCode == 27) {
          let btn = document.querySelector('button.add-data-cancel[data-id-lead="'+id_lead+'"]');
          btn.click();
        }
        if (e.keyCode == 13) {
          let btn = document.querySelector('button.add-data-submit[data-id-lead="'+id_lead+'"]');
          btn.click();
        }
      });
  
}

function init_lead_reminders() {
    // hide .add-reminder-div
    $('.add-reminder-div').hide();
    // show .add-reminder-div when .add-reminder is clicked
    $('.add-reminder').click(function() {
        let id_lead = $(this).attr('data-id-lead');
        let div = document.querySelector('div.add-reminder-div[data-id-lead="'+id_lead+'"]');
        $(div).show();
        $(div).find('textarea').focus();
    });
    // hide .add-data-div when .add-data-cancel is clicked
    $('.add-reminder-cancel').click(function() {
        let id_lead = $(this).attr('data-id-lead');
        let div = document.querySelector('div.add-reminder-div[data-id-lead="'+id_lead+'"]');
        $(div).hide();
      });
  
      // ajax call to /leads/ajax/add_data.json when the user clicks on .add-data-submit
      $('.add-reminder-submit').click(function () {
        let id_lead = $(this).attr('data-id-lead');
        let period_number = $(this).attr('data-period-number');
        let period_unit = $(this).attr('data-period-unit');
        let input_description = document.querySelector('textarea.add-reminder-description[data-id-lead="'+id_lead+'"]'); 
        let div = document.querySelector('div.add-reminder-div[data-id-lead="'+id_lead+'"]');
        let div_data = document.querySelector('div.contact-info[data-id-lead="'+id_lead+'"]');
        // hide form
        $(div).hide();
        // show adding legend
        div_data.innerHTML = 'adding reminder...';      
        // ajax call
        $.ajax({
          url: '/ajax/leads/add_reminder.json',
          type: 'POST',
          data: { id_lead: id_lead, description: input_description.value, period_number: period_number, period_unit: period_unit },
          success: function(data) {
            // get the json response
            let response = JSON.parse(data);
            if (response.status == 'success') {
              unlock_data(id_lead);
            } else {
              alert(response.status);
              alert('An error occured trying to add data to the lead. Error: ' + response.status);
            }
          }, error: function(data) {
            // get the json response
            let response = JSON.parse(data);
            alert('Unknown error occured trying to add data to the lead.');
          }
        });      
      });
      // fire .add-data-cancel when :esc is pressed on .add-data-value
      // fire .add-data-submit when :enter is pressed on .add-data-value
      $('.add-reminder-description').keyup(function(e) {
        let id_lead = $(this).attr('data-id-lead');      
        if (e.keyCode == 27) {
          let btn = document.querySelector('button.add-reminder-cancel[data-id-lead="'+id_lead+'"]');
          btn.click();
        }
        if (e.keyCode == 13) {
          let btn = document.querySelector('button.add-reminder-submit[data-id-lead="'+id_lead+'"]');
          btn.click();
        }
      });
  
}

function init_lead_exports() {
    // en endit any textfield inside a ul,
    // enable/disable the add button depending on the value of the textfield
    // by calling function enable_add_button(id_lead)
    $('ul.ul-export-lists').on('keyup', 'input.input-export-lists', function() {
        enable_add_button($(this).closest('ul').data('id-lead'));
      });
  
      // better user experience: when click on any export button, 
      // 1. disable the textfield
      // 2. disable the add button
      // 3. set '<center><i>Loading...</i></center>' as innerhtml of the div
      // 4. call ajax to bring the full list of export lists, and wich are linked to this lead
      // 5. add the export lists to the div.div-export-lists
      // 6. enable the textfield 
      // 7. call function to enable/disable the add button depending on the value of the textfield
      // 8. set focus on the textfield
      $('button.btn-export-lists').click(function() {
        let id_lead = $(this).data('id-lead');
        let div = document.querySelector('div.div-export-lists[data-id-lead="'+id_lead+'"]');
        // 1. disable the textfield
        $('ul.ul-export-lists[data-id-lead="'+id_lead+'"] input.input-export-lists').prop('disabled', true);
        // 2. disable the add button
        $('ul.ul-export-lists[data-id-lead="'+id_lead+'"] button.btn-create-export-list').prop('disabled', true);
        // 3. set '<center><i>Loading...</i></center>' as innerhtml of the div
        div.innerHTML = '<center><i>Loading...</i></center>';
        // 4. call ajax to bring the full list of export lists, and wich are linked to this lead
        $.ajax({
          url: '/ajax/leads/get_lists_linked_to_lead.json',
          type: 'POST',
          data: { id_lead: id_lead, name: name },
          success: function(data) {
            // get the json response
            let response = JSON.parse(data);
            if (response.status == 'success') {
              // 5. add the export lists to the div.div-export-lists          
              // remove all the lists
              div.innerHTML = '';
              response.exports.forEach(function(h) { 
                add_export_list(id_lead, h);
              });
              // if there are no exports to show, show a message
              if (response.exports.length == 0) {
                // find the div
                let div = document.querySelector('div.div-export-lists[data-id-lead="'+id_lead+'"]');
                // create the li element, with hand cursor
                let li = document.createElement('li');
                let center = document.createElement('center');
                let i = document.createElement('i');
                i.innerHTML = 'No export lists found';
                center.appendChild(i);
                li.appendChild(center);
                // add the li to the ul
                $(div).append(li);          
              }
              // 6. enable the textfield 
              $('ul.ul-export-lists[data-id-lead="'+id_lead+'"] input.input-export-lists').prop('disabled', false);
              // 7. call function to enable/disable the add button depending on the value of the textfield
              enable_add_button(id_lead);
              // 8. set focus on the textfield
              // becuase of any other javascript conflic, I have to  add a delay of 100ms before focus the inputbox.
              setTimeout(function() {
                $('ul.ul-export-lists[data-id-lead="'+id_lead+'"] li input.input-export-lists').focus();
              }, 100);      
            } else {
              alert(response.status);
              alert('An error occured trying to load the export lists. Error: ' + response.status);
            }
          }, error: function(data) {
            // get the json response
            let response = JSON.parse(data);
            alert('Unknown error occured when loading the export lists.');
          }
        });
      });  
  
      // better user experience: when click on the '+ add' button, 
      // 1. call AJAX to create the new list
      // 2. add the new list to all the export list dropdown
      // 3. delete the content of the input box
      $('button.btn-create-export-list').click(function(e) {
        // variables
        let name = $(this).parent().find('input.input-export-lists').val();
        let id_lead = $(this).data('id-lead');
        // 1. call AJAX to create the new list
        $.ajax({
          url: '/ajax/leads/create_export_list_and_add_lead.json',
          type: 'POST',
          data: { id_lead: id_lead, name: name },
          success: function(data) {
            // get the json response
            let response = JSON.parse(data);
            if (response.status == 'success') {
              // remove the dummy li now that I received the ID of the new export list.
              remove_export_list(id_lead, '123');
              // 2. add the new list to this the export list dropdown
              add_export_list(id_lead, {id: response.id_export, filename: name, belonging: true});
              // update the credits in the header
              i2p_update_header('leads');
            } else {
              if ( response.status =~ /No Credits/ ) {
                window.location.replace('/plans');
              } else {
                alert('An error occured while creating the new list:' + name + '. Error: ' + response.status);
              }
            }
          },
          error: function(data) {
            alert('Unknown error occured while creating the new list:' + name);
          }
        });
        // better user experience: unlock data immedaitelly after the ajax call. don't wait for response because of an ux matter. 
        // unlock contact info
        unlock_data(id_lead);
        // better user experience: the new list is added immedaitelly after the ajax call. don't wait for response because of an ux matter. 
        // so I add a dummy li until I receive the ID of the new export list.
        add_export_list(id_lead, {id: '123', filename: name, belonging: true}, '0.5');
        // 3. delete the content of the input box belinging the parent ul element
        $('input.input-export-lists[data-id-lead="'+id_lead+'"]').val('');
        // JavaScript, stop additional event listeners
        // reference: https://www.w3schools.com/jsref/event_stopimmediatepropagation.asp
        e.stopImmediatePropagation();
      });
  
      // avoid to close the ul when click on the input box
      $('input.input-export-lists').click(function(e) {
        // JavaScript, stop additional event listeners
        // reference: https://www.w3schools.com/jsref/event_stopimmediatepropagation.asp
        e.stopImmediatePropagation();
      });
  
      // better user experience: when press ENTER on any .input-export-lists, for click on the add button with same data-id-lead.
      $('input.input-export-lists').keypress(function(e) {
        if (e.which == 13) {
          // find button .btn-create-export-list with same data-id-lead value
          let id_lead = $(this).attr('data-id-lead');
          let button = $('button.btn-create-export-list[data-id-lead="'+id_lead+'"]');
          // if button is enabled
          if ( button.prop('disabled') == false ) {
            // click the button
            button.click();
          }
        }
      });  
}