import os
import glob
from reportlab.lib.pagesizes import letter
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, PageBreak
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.units import inch

def convert_graydon_talks_to_pdf():
    # Get all .md files from graydon_talks directory
    md_files = glob.glob('graydon_talks/*.md')
    md_files.sort()  # Sort files in order
    
    if not md_files:
        print("No markdown files found in graydon_talks/ directory")
        return
    
    # Create PDF document
    doc = SimpleDocTemplate(
        "graydon_talks_combined.pdf",
        pagesize=letter,
        rightMargin=72,
        leftMargin=72,
        topMargin=72,
        bottomMargin=18,
    )
    
    # Get styles
    styles = getSampleStyleSheet()
    title_style = styles['Heading1']
    body_style = styles['Normal']
    body_style.fontSize = 10
    body_style.leading = 12
    
    # Build story
    story = []
    
    # Add title page
    title = Paragraph("Graydon's MKC Talks Collection", styles['Title'])
    story.append(title)
    story.append(Spacer(1, 0.5*inch))
    
    subtitle = Paragraph(f"All 58 talks from the MKC series", styles['Heading2'])
    story.append(subtitle)
    story.append(PageBreak())
    
    # Process each file
    for md_file in md_files:
        filename = os.path.basename(md_file)
        talk_num = filename.replace('mkp', '').replace('.md', '')
        print(f"Processing {filename}...")
        
        # Add title for this talk
        talk_title = Paragraph(f"Talk {int(talk_num)} - MKC Series", title_style)
        story.append(talk_title)
        story.append(Spacer(1, 0.2*inch))
        
        with open(md_file, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Skip the markdown title line
        lines = content.split('\n')
        if lines and lines[0].startswith('#'):
            lines = lines[3:]  # Skip title and empty lines
        
        # Add content
        for line in lines:
            if line.strip():
                # Remove code block markers
                line = line.replace('```', '')
                if line.strip():
                    para = Paragraph(line.strip(), body_style)
                    story.append(para)
            else:
                story.append(Spacer(1, 6))
        
        # Add page break between files
        story.append(PageBreak())
    
    # Build PDF
    doc.build(story)
    print(f"Successfully converted {len(md_files)} .md files to graydon_talks_combined.pdf")

if __name__ == "__main__":
    convert_graydon_talks_to_pdf()