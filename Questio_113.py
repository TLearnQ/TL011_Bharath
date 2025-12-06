data = {'lab_machine1':45, 
        'lab_machine2':67,
        'lab_machine3':89,
        'lab_machine4':23,
        'lab_machine5':56
        }
for i, v in data:
    if v < 30:
        print('idle')
    elif v < 60 and v > 30:
        print('Normal')

    elif v > 60 and v < 90:
        print("Busy")
    else:
        print("Over Load!")

print(data)

