from faker_netflix import Netflix


netflix = Netflix()

if __name__ == '__main__':
    #Creamos 1000 Nodos, si ya se ha corrido una vez es necesario mover el rango de creación de los index
    netflix.create_nodes(1, 1000)

    #Creamos 10000 relaciones de tipo ADD
    netflix.create_relationships(10000)
    