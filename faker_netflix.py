from neo4j import GraphDatabase
from dotenv import load_dotenv
import os 
import random 

load_dotenv()

class Netflix:

    def __init__(self):
        self.uri = os.getenv("URI")
        self.username = os.getenv("USERNAME")
        self.password = os.getenv("PASSWORD")
        self.driver = GraphDatabase.driver(self.uri, auth=(self.username, self.password))
        self.session = self.driver.session()
        pass

    def create_nodes(self, starting_id, finish_id):
        for num_id in range(starting_id, finish_id + 1):
            query = (
                f"CREATE (p:Profile {{id:{num_id}}})"
                    )   
            self.session.run(query)
            print(f'El nodo con id: {num_id} ha sido creado exitosamente')
        

    def create_relationships(self, num_relationships):
        movies_ids = [record["id"] for record in self.session.run("MATCH (m:Movie) RETURN m.id AS id")]
        profiles_ids = [record["id"] for record in self.session.run("MATCH (p:Profile) RETURN p.id AS id")]
        with self.session.begin_transaction() as tx:
            for i in range(num_relationships):
                profile = random.choice(profiles_ids)
                movie = random.choice(movies_ids)
                
                query_rel = """
                MATCH (p:Profile {id: $profile_id}), (m:Movie {id: $movie_id})
                MERGE (p)-[:ADD]->(m)
                """
                tx.run(query_rel, profile_id=profile, movie_id=movie)

        print('Relaciones creadas exitosamente')