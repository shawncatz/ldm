$(document).on "click", ".user-password", (event)->
  console.log "user password"
  e = $(event.target)
  l = e.data("login")
  bootbox.dialog
    title: "new password for "+l
    message: $("#user-password-dialog").html()
    buttons:
      success:
        label: "Change"
        className: "btn-success"
        callback: ->
          f = $(".bootbox-body .user-password-form").serializeArray()
          console.debug f
          data = {}
          $.each f, (i, input)->
            data[input.name] = input.value
          console.log data
          $.ajax
            url: '/users/'+l+'/password'
            dataType: 'json'
            method: 'POST'
            data: {login: l, password: data.password, confirm: data.confirm}
            error: (xhr, status, thrown)->
              toastr["error"](xhr.responseJSON.error)
            success: (data)->
              toastr["success"]("password changed!")

