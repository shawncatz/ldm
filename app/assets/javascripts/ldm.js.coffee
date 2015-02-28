$(document).on "click", "a.user-password", (event)->
  console.log "user password"
  l = $(event.currentTarget).data("login")
  bootbox.dialog
    title: "new password for "+l
    message: $("#user-password-dialog").html()
    buttons:
      success:
        label: "Change"
        className: "btn-success"
        callback: ->
          f = $(".bootbox-body .user-password-form").serializeArray()
#          console.debug f
          data = {}
          $.each f, (i, input)->
            data[input.name] = input.value
#          console.log data
          $.ajax
            url: '/users/'+l+'/password'
            dataType: 'json'
            method: 'POST'
            data: {login: l, password: data.password, confirm: data.confirm}
            error: (xhr, status, thrown)->
              toastr["error"](xhr.responseJSON.error)
            success: (data)->
              toastr["success"](data.message)

$(document).on "click", "a.user-disable", (event)->
  console.log "user disable"
  l = $(event.currentTarget).data("login")
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

$(document).on "click", "a.user-enable", (event)->
  console.log "user disable"
  l = $(event.currentTarget).data("login")
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

$("a.user-group-add").on "click", (event)->
  l = $(event.currentTarget).data("login")
  console.log "user add to group: "+l
  bootbox.prompt
    title: "Add group"
    callback: (result)->
      console.log "result="+result
      if result
        $.ajax
          url: '/users/'+l+'/groups'
          dataType: 'json'
          method: 'POST'
          data: {login: l, group: result}
          error: (xhr, status, thrown)->
            toastr["error"](xhr.responseJSON.error)
          success: (data)->
            toastr["success"](data.message)

$(document).on "click", "a.user-group-remove", (event)->
  e = $(event.currentTarget)
  l = e.data("login")
  g = e.data("group")
  console.log "user remove from group:"+l+" "+g
  bootbox.confirm "Remove "+l+" from group "+g+"?", (result)->
      console.log "result="+result
      if result
        $.ajax
          url: '/users/'+l+'/groups/'+g
          dataType: 'json'
          method: 'DELETE'
          data: {login: l, group: g}
          error: (xhr, status, thrown)->
            toastr["error"](xhr.responseJSON.error)
          success: (data)->
            toastr["success"](data.message)

$(document).on "click", "a.user-key-add", (event)->
  l = $(event.currentTarget).data("login")
  console.log "user add key: "+l
  bootbox.prompt
    title: "Add key"
    callback: (result)->
      console.log "result="+result
      if result
        $.ajax
          url: '/users/'+l+'/keys'
          dataType: 'json'
          method: 'POST'
          data: {login: l, key: result}
          error: (xhr, status, thrown)->
            toastr["error"](xhr.responseJSON.error)
          success: (data)->
            toastr["success"](data.message)

$(document).on "click", "a.user-key-remove", (event)->
  e = $(event.currentTarget)
  l = e.data("login")
  k = e.data("key")
  console.log "user add key: "+l
  bootbox.confirm "Are you sure you want to remove key?", (result)->
    console.log "result="+result
    if result
      $.ajax
        url: '/users/'+l+'/keys/remove'
        dataType: 'json'
        method: 'DELETE'
        data: {login: l, key_name: k}
        error: (xhr, status, thrown)->
          toastr["error"](xhr.responseJSON.error)
        success: (data)->
          toastr["success"](data.message)

$(document).on "click", "a.user-create", (event)->
  e = $(event.currentTarget)
  console.log "user create"
  bootbox.dialog
    title: "create new user"
    message: $("#user-create-dialog").html()
    buttons:
      success:
        label: "Create"
        className: "btn-success"
        callback: ->
          f = $(".bootbox-body .user-create-form").serializeArray()
#          console.debug f
          data = {}
          $.each f, (i, input)->
            data[input.name] = input.value
          console.log data
          $.ajax
            url: '/users'
            dataType: 'json'
            method: 'POST'
            data: {user: data}
            error: (xhr, status, thrown)->
              toastr["error"](xhr.responseJSON.error)
            success: (data)->
              toastr["success"](data.message)

$(document).on "click", "a.group-create", (event)->
  e = $(event.currentTarget)
  console.log "group create"
  bootbox.prompt
    title: "create new group"
    callback: (result)->
      if result
        $.ajax
          url: '/groups'
          dataType: 'json'
          method: 'POST'
          data: {group: {name: result}}
          error: (xhr, status, thrown)->
            toastr["error"](xhr.responseJSON.error)
          success: (data)->
            toastr["success"](data.message)

$(document).on "click", "a.group-user-add", (event)->
  e = $(event.currentTarget)
  g = e.data("group")
  console.log "group user add"
  bootbox.prompt
    title: "add user to group"
    callback: (result)->
      if result
        $.ajax
          url: '/groups/'+g+'/users'
          dataType: 'json'
          method: 'POST'
          data: {group: {name: g, user: result}}
          error: (xhr, status, thrown)->
            toastr["error"](xhr.responseJSON.error)
          success: (data)->
            toastr["success"](data.message)

