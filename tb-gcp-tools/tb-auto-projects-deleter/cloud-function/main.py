from checks.system_check import run_system_checks
from deleter import run_delete_task, send_teams_message


def system_test(event, context):
    print("""This Function was triggered by messageId {} published at {}
    """.format(context.event_id, context.timestamp))

    try:
        run_system_checks()
    except Exception as e:
        send_teams_message('<strong style="color:red;">Error running system checks</strong>')
        raise Exception("Error running system checks " + str(e))


def delete_tbase_deployments(event, context):
    print("""This Function was triggered by messageId {} published at {}
    """.format(context.event_id, context.timestamp))
    try:
        run_system_checks()
        run_delete_task()
    except Exception as e:
        send_teams_message('<strong style="color:red;">Error running delete task</strong>')
        raise Exception("Error running delete task " + str(e))


if __name__ == "__main__":
    run_system_checks()
    run_delete_task()
