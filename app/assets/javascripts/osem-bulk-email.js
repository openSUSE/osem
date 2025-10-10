$(document).ready(function() {
  // Bulk Email Recipient Management

  // Select All button
  $('#select-all-btn').click(function() {
    $('.recipient-checkbox').prop('checked', true);
    updateRecipientCount();
  });

  // Deselect All button
  $('#deselect-all-btn').click(function() {
    $('.recipient-checkbox').prop('checked', false);
    updateRecipientCount();
  });

  // Remove Selected button
  $('#remove-selected-btn').click(function() {
    $('.recipient-checkbox:checked').each(function() {
      $(this).closest('.recipient-item').slideUp(300, function() {
        $(this).remove();
        updateRecipientCount();
      });
    });
  });

  // Update count when individual checkboxes are changed
  $(document).on('change', '.recipient-checkbox', function() {
    updateRecipientCount();
  });

  // Update recipient count display
  function updateRecipientCount() {
    var checkedCount = $('.recipient-checkbox:checked').length;
    var totalCount = $('.recipient-checkbox').length;
    $('#recipient-count').text(totalCount);

    // Update the next button state
    if (checkedCount === 0) {
      $('#next-compose-btn').prop('disabled', true).text('Select Recipients First');
    } else {
      $('#next-compose-btn').prop('disabled', false).text('Next: Compose Email (' + checkedCount + ' selected)');
    }
  }

  // Initialize count on page load
  if ($('.recipient-checkbox').length > 0) {
    updateRecipientCount();
  }

  // Form validation for recipients step
  $('#recipients-form').submit(function(e) {
    var checkedCount = $('.recipient-checkbox:checked').length;
    if (checkedCount === 0) {
      e.preventDefault();
      alert('Please select at least one recipient before proceeding.');
      return false;
    }
  });

  // Dynamic recipient filtering (if needed for future enhancement)
  $('#filter-recipients-input').on('keyup', function() {
    var value = $(this).val().toLowerCase();
    $('.recipient-item').filter(function() {
      $(this).toggle($(this).text().toLowerCase().indexOf(value) > -1);
    });
  });

  // Preview email functionality
  $('#preview-email-btn').click(function() {
    var subject = $('#subject').val();
    var body = $('#body').val();

    if (subject.trim() === '' || body.trim() === '') {
      alert('Please enter both subject and body before previewing.');
      return;
    }

    // Create preview modal (assuming Bootstrap modal)
    var modalHtml = '<div class="modal fade" id="email-preview-modal" tabindex="-1">' +
                    '<div class="modal-dialog modal-lg">' +
                    '<div class="modal-content">' +
                    '<div class="modal-header">' +
                    '<button type="button" class="close" data-dismiss="modal">&times;</button>' +
                    '<h4 class="modal-title">Email Preview</h4>' +
                    '</div>' +
                    '<div class="modal-body">' +
                    '<p><strong>Subject:</strong> ' + subject + '</p>' +
                    '<hr>' +
                    '<div style="white-space: pre-wrap;">' + body + '</div>' +
                    '</div>' +
                    '<div class="modal-footer">' +
                    '<button type="button" class="btn btn-default" data-dismiss="modal">Close</button>' +
                    '</div>' +
                    '</div>' +
                    '</div>' +
                    '</div>';

    $('body').append(modalHtml);
    $('#email-preview-modal').modal('show').on('hidden.bs.modal', function() {
      $(this).remove();
    });
  });

  // Character counter for email body
  $('#body').on('input', function() {
    var length = $(this).val().length;
    var counter = $('#char-counter');
    if (counter.length === 0) {
      $(this).after('<small id="char-counter" class="text-muted">Characters: 0</small>');
      counter = $('#char-counter');
    }
    counter.text('Characters: ' + length);
  });

  // Auto-save draft functionality (localStorage)
  var draftKey = 'bulk-email-draft-' + window.location.pathname;

  // Load draft on page load
  if (localStorage.getItem(draftKey)) {
    var draft = JSON.parse(localStorage.getItem(draftKey));
    if (draft.subject) $('#subject').val(draft.subject);
    if (draft.body) $('#body').val(draft.body);

    if (draft.subject || draft.body) {
      $('<div class="alert alert-info">').text('Draft restored from previous session.').insertBefore('form');
    }
  }

  // Save draft as user types
  $('#subject, #body').on('input', function() {
    var draft = {
      subject: $('#subject').val(),
      body: $('#body').val(),
      timestamp: new Date().toISOString()
    };
    localStorage.setItem(draftKey, JSON.stringify(draft));
  });

  // Clear draft on successful send
  $('form[action*="send_bulk"]').submit(function() {
    localStorage.removeItem(draftKey);
  });
});