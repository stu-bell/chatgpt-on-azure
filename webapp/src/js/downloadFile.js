function downloadFile(content, fileName) {
    // Create a Blob from the content
    const data = new Blob([content], { type: 'text/plain' });

    // Create a URL that points to the Blob
    const url = URL.createObjectURL(data);

    // Create a link element
    const link = document.createElement('a');

    // Set the URL and filename on the link
    link.href = url;
    link.download = fileName;

    // Add the link to the DOM (needed for Firefox)
    document.body.appendChild(link);

    // Programmatically click the link
    link.click();

    // Remove the link from the DOM
    document.body.removeChild(link);
}

export default downloadFile