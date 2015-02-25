$(document).on "click", ".user-password", (event)->
  console.log "user password"
  l = $(event.target).data("login")
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
              toastr["success"](data.message)

$(document).on "click", ".user-disable", (event)->
  console.log "user disable"
  l = $(event.target).data("login")
  bootbox.confirm "Are you sure you want to disable "+l+"?", (result)->
    console.log "result="+result
    if result
      $.ajax
        url: '/users/'+l+'/disable'
        dataType: 'json'
        method: 'POST'
        data: {login: l}
        error: (xhr, status, thrown)->
          toastr["error"](xhr.responseJSON.error)
        success: (data)->
          toastr["success"](data.message)

$(document).on "click", ".user-enable", (event)->
  console.log "user disable"
  l = $(event.target).data("login")
  bootbox.confirm "Are you sure you want to enable "+l+"?", (result)->
    console.log "result="+result
    if result
      $.ajax
        url: '/users/'+l+'/enable'
        dataType: 'json'
        method: 'POST'
        data: {login: l}
        error: (xhr, status, thrown)->
          toastr["error"](xhr.responseJSON.error)
        success: (data)->
          toastr["success"](data.message)
