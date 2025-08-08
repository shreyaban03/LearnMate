from gtts import gTTS
import uuid
import os


def text_to_speech(text:str)->str:
  filename=f"{uuid.uuid4().hex}.mp3"
  filepath=os.path.join("static",filename)
  os.makedirs("static",exist_ok=True)


  tts=gTTS(text)
  tts.save(filepath)

  return filepath
