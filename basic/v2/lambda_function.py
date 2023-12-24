def handler(event, contexts):
  print(event)
  user = event.get('user', None)
  return f'Hello {user} from lambda v2~~'