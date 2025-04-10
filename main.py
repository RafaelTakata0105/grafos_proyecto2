from faker_netflix import Netflix
import os

netflix = Netflix()

if __name__ == '__main__':
    netflix.create_nodes(13, 14)
    