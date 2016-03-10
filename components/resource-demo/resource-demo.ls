class Demo
  -> @ <<< it

class ResourceDemo
  is: \resource-demo
  behaviors: [Polymer.GladResourceUserBehavior]
  resource_class: Demo
  properties:
    namespace:
      value: \demo
    url:
      value: \/demos

|> ( .::) |> Polymer


