from google.cloud import firestore

def get_db() -> firestore.Client:
    #Uses GOOGLE_APPLICATION_CREDENTIALS automatically
    return firestore.Client()

