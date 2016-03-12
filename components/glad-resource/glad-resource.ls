{id, reject, filter, find, obj-to-pairs, each, elem-index, map, last, pairs-to-obj} = Polymer.GladPreludeLs
elms = {}

class Resource

class GladResource
  is: \glad-resource
  listeners:
    fetched: \_fire_changed
    changed: \set_instances

  # Private
  _new_ajax:~ -> document.create-element \iron-ajax
  _elms:~ -> elms.[][@_namespace]
  _same_key_elms:~ -> @_elms |> filter ~> it._meta_key is @_meta_key
  _instances:~ -> @_get_meta "instances-#{@_meta_key}"
  _iron_request_to_fetch:~ -> @_get_meta "iron-request-to-fetch-#{@_meta_key}"
  _url_to_fetch:~ -> @dom-host.url
  _url_to_persist:~ -> @dom-host.url
  _url_to_update: (instance)-> "#{@dom-host.url}/#{instance.id}"
  _url_to_delete: (instance)-> "#{@dom-host.url}/#{instance.id}"
  _params_to_fetch:~ -> @dom-host.params
  _meta_key:~ -> "#{@_namespace}-#{@dom-host.meta_key or \$}"
  _namespace:~ -> @dom-host.namespace
  _get_meta: (key)-> @$.meta.by-key key
  _set_meta: (key, value)-> @$.meta._register-key-value key, value
  _let_signal_listen: ->
    <[fetched changed]>
    |> each (event_name)~>
      @listen @$.signals, "iron-signal-resource-#{@_namespace}-#event_name", "_listener_for_#{event_name}"
  _listener_for_fetched: (_, {key})->
    if key isnt @_meta_key => return
    @fire \fetched, instances: @_instances, host: @dom-host
  _listener_for_changed: (_, {key})->
    if key isnt @_meta_key => return
    @fire \changed, instances: @_instances, host: @dom-host
  _set_meta_type: ->
    @set \_meta_type, "glad-resource-#{@_namespace}"
  _fire_changed: -> @fire \changed
  _instantiate: (seed)-> new @dom-host.resource_class seed
  _fetch: (cb)->
    if @_iron_request_to_fetch? then return
    (ajax = @_new_ajax)
      ..set \method, \GET
      ..set \url, @_url_to_fetch
      ..set \params, @_params_to_fetch
      ..generate-request! |> ~>
        it.cb = cb
        it.ajax = ajax
        @_set_meta "iron-request-to-fetch-#{@_meta_key}", it
    @listen ajax, \response, \_complete_to_fetch
  _complete_to_fetch: (_, {cb, ajax})~>
    @_set_meta "instances-#{@_meta_key}", (ajax.last-response |> map @~_instantiate)
    @fire \iron-signal, name: "resource-#{@_namespace}-fetched", data: key: @_meta_key
    @_set_meta "iron-request-to-fetch-#{@_meta_key}", undefined
  _save: (instance, cb)->
    | not instance.id? => @_persist ...
    | _ => @_update ...
  _persist: (instance, cb)->
    if instance@@ isnt @dom-host.resource_class then instance = @_create instance
    (ajax = @_new_ajax)
      ..set \method, \POST
      ..set \url, @_url_to_persist
      ..set \contentType, "application/json"
      ..set \body, instance
      ..generate-request! |> ( .cb = cb; it.instance = instance; it.ajax = ajax)
    @listen ajax, \response, \_complete_to_persist
  _complete_to_persist: (_, {cb, instance, ajax})->
    @_set_meta "instances-#{@_meta_key}", (@_instances ++ (instance <<< ajax.last-response))
    @fire \iron-signal, name: "resource-#{@_namespace}-changed", data: key: @_meta_key
    cb? null, instance
  _update: (instance, cb)->
    (ajax = @_new_ajax)
      ..set \method, \PUT
      ..set \url, @_url_to_update instance
      ..set \contentType, "application/json"
      ..set \body, instance
      ..generate-request! |> ( .cb = cb; it.instance = instance; it.ajax = ajax)
    @listen ajax, \response, \_complete_to_update
  _complete_to_update: (_, {cb, instance, ajax})~>
    @_set_meta "instances-#{@_meta_key}", (
      @_instances
      |> map ~>
        if it is instance then @_instantiate (instance <<< ajax.last-response)
        else it
    )
    @fire \iron-signal, name: "resource-#{@_namespace}-changed", data: key: @_meta_key
    cb? null, instance
  _delete: (instance, cb)->
    (ajax = @_new_ajax)
      ..set \method, \DELETE
      ..set \url, @_url_to_delete instance
      ..set \contentType, "application/json"
      ..set \body, instance
      ..generate-request! |> ( .cb = cb; it.instance = instance; it.ajax = ajax)
    @listen ajax, \response, \_complete_to_delete
  _complete_to_delete: (_, {cb, instance, ajax})~>
    @_set_meta "instances-#{@_meta_key}", (@_instances |> reject (is) instance)
    @fire \iron-signal, name: "resource-#{@_namespace}-changed", data: key: @_meta_key
    cb? null, instance
  _set_instances: ->
    @debounce \set_instances, ~>
      @dom-host.set \instances, @_instances
      if not @dom-host.instances? then @fetch!
    , 100
  _create: -> new ((_class = @dom-host.resource_class).bind.apply _class, ([_class] ++ (& |> map id)))

  # Public
  fetch: -> @_fetch ...
  save: -> @_save ...
  persist: -> @_persist ...
  update: -> @_update ...
  delete: -> @_delete ...
  set_instances: -> @_set_instances ...
  create: -> @_create ...

  # Initialization
  attached: ->
    @_set_meta_type!
    elms.[][@_namespace].push @
    @_let_signal_listen!
    if @dom-host.auto-fetch then @set_instances!

|> ( .::) |> Polymer

Polymer.GladResourceUserBehavior = {}
  # Interfaces
  # namespace: String
  # url: String
  # params: Object
  # meta_key: String
  # resource_class: Resource
  ..<<<
    properties:
      auto-fetch:
        value: on
      instances:
        type: Array
        notify: on
  ..<<<
    <[fetch save persist update delete set_instances create]>
    |> map (method_name)->
      [method_name, ->
        (elm = @$$ \glad-resource).(method_name).apply elm, &
      ]
    |> pairs-to-obj


