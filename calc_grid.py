for i in range(3):
    print ("GRID_X_TOP_{} equ {}").format(i, ((92 * i) + 20))
    print ("GRID_X_CNT_{} equ {}").format(i, (190 - (92 * i)))
    print ("GRID_X_BOT_{} equ {}").format(i, (365 - (92 * i)))
