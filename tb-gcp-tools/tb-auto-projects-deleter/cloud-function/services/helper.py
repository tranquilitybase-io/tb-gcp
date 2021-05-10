def handle_permission_error(exception: Exception, message: str):
    if "not have permission" in str(exception):
        print(str(exception))
        print(message)
    else:
        raise exception
