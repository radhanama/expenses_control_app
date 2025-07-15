import argparse
import google.genai as genai
from google.genai import types


def caption_image(image_path: str, api_key: str) -> None:
    """Generate a caption for an image using Gemini 2.5 Flash."""
    genai.configure(api_key=api_key)
    client = genai.Client()

    with open(image_path, 'rb') as f:
        image_bytes = f.read()

    response = client.models.generate_content(
        model='gemini-2.5-flash',
        contents=[
            types.Part.from_bytes(data=image_bytes, mime_type='image/jpeg'),
            'Caption this image.'
        ]
    )
    print(response.text)


def main():
    parser = argparse.ArgumentParser(description='Caption an image using Gemini 2.5 Flash')
    parser.add_argument('api_key', help='Google Generative AI API key')
    parser.add_argument('image', help='Path to the JPEG image to caption')
    args = parser.parse_args()
    caption_image(args.image, args.api_key)


if __name__ == '__main__':
    main()
