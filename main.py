from faker_netflix import Netflix
import os

netflix = Netflix()

if __name__ == '__main__':
    #Creamos 100 Nodos, si ya se ha corrido una vez es necesario mover el rango de creación de los index
    netflix.create_nodes(15, 100)

    #Creamos 10000 relaciones de tipo ADD
    netflix.create_relationships(10000)
    