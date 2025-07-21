import requests
import os

# Base URL for the talks
def scrape_talks():
    base_url = "http://venge.net/graydon/talks/mkc/html/mgp{:05d}.txt"
    
    # Create directory for the talks
    os.makedirs("graydon_talks", exist_ok=True)
    
    # Scrape each talk from 1 to 58
    for i in range(1, 59):
        url = base_url.format(i)
        filename = f"mkp{i:05d}.md"
        filepath = os.path.join("graydon_talks", filename)
        
        try:
            print(f"Fetching {url}...")
            response = requests.get(url, timeout=30)
            response.raise_for_status()
            
            # Convert plain text to markdown format
            content = response.text
            
            # Create markdown with proper title
            title = f"Talk {i} - Graydon's MKC Series"
            markdown_content = f"# {title}\n\n```\n{content}\n```"
            
            # Save as markdown
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(markdown_content)
            
            print(f"Saved {filename}")
            
        except requests.exceptions.RequestException as e:
            print(f"Failed to fetch {url}: {e}")
        except Exception as e:
            print(f"Error processing {url}: {e}")

if __name__ == "__main__":
    scrape_talks()