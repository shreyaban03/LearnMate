from moviepy.editor import AudioFileClip, ImageClip
import uuid
import os
from utils.text_to_speech import text_to_speech

def create_lottie_video(text: str, image_path: str = None) -> str:
    try:
        audio_filename = text_to_speech(text)
        audio_path = os.path.join("static", audio_filename)
        
        if image_path is None or image_path == "":
            image_path = os.path.join("static", "default_image.png")
        
        if not os.path.exists(audio_path):
            raise FileNotFoundError(f"Audio file not found: {audio_path}")
        if not os.path.exists(image_path):
            raise FileNotFoundError(f"Image file not found: {image_path}")
        
        audio = AudioFileClip(audio_path)
        image_clip = ImageClip(image_path).set_duration(audio.duration).set_audio(audio)
        image_clip = image_clip.resize(height=720)
        
        output_filename = f"video_{uuid.uuid4().hex}.mp4"
        output_path = os.path.join("static", output_filename)
        
        os.makedirs("static", exist_ok=True)
        
        image_clip.write_videofile(
            output_path,
            codec="libx264",
            audio_codec="aac",
            temp_audiofile="temp-audio.m4a",
            remove_temp=True,
            verbose=False,
            logger=None
        )
        
        audio.close()
        image_clip.close()
        
        return output_filename
        
    except Exception as e:
        print(f"Error creating video: {str(e)}")
        if 'audio' in locals():
            audio.close()
        if 'image_clip' in locals():
            image_clip.close()
        raise e

# def create_lottie_video_with_placeholder(text: str, image_path: str = None) -> str:
#     import numpy as np
#     from PIL import Image
    
#     try:
#         audio_filename = text_to_speech(text)
#         audio_path = os.path.join("static", audio_filename)
        
#         if image_path is None or image_path == "" or not os.path.exists(image_path):
#             placeholder_path = os.path.join("static", f"placeholder_{uuid.uuid4().hex}.png")
            
#             img_array = np.zeros((720, 1280, 3), dtype=np.uint8)
#             img_array[:, :, 0] = 100
#             img_array[:, :, 1] = 150
#             img_array[:, :, 2] = 200
            
#             img = Image.fromarray(img_array)
#             img.save(placeholder_path)
#             image_path = placeholder_path
        
#         audio = AudioFileClip(audio_path)
#         image_clip = ImageClip(image_path).set_duration(audio.duration).set_audio(audio)
#         image_clip = image_clip.resize(height=720)
        
#         output_filename = f"video_{uuid.uuid4().hex}.mp4"
#         output_path = os.path.join("static", output_filename)
        
#         os.makedirs("static", exist_ok=True)
        
#         image_clip.write_videofile(
#             output_path,
#             codec="libx264",
#             audio_codec="aac",
#             temp_audiofile="temp-audio.m4a",
#             remove_temp=True,
#             verbose=False,
#             logger=None
#         )
        
#         audio.close()
#         image_clip.close()
        
#         return output_filename
        
#     except Exception as e:
#         print(f"Error creating video: {str(e)}")
#         if 'audio' in locals():
#             audio.close()
#         if 'image_clip' in locals():
#             image_clip.close()
#         raise e



