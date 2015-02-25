$(document).on "click", ".user-password", (event)->
  console.log "user password"
  e = $(event.target)
  l = e.data("login")
  bootbox.prompt
    title: "new password"
    callback: (result)->
      $.ajax
        url: '/users/'+l+'/password'
        dataType: 'json'
        method: 'POST'
        data: {login: l, password: result}
        error: (xhr, status, thrown)->
          console.error "error: "+status
        success: (data)->
          console.log "returned: "+data

