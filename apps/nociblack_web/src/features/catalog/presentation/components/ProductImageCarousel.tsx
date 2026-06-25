import { useState } from "react";

import styles from "./ProductImageCarousel.module.css";

type ProductImageCarouselProps = {
  imageUrls: string[];
  title: string;
};

export function ProductImageCarousel({
  imageUrls,
  title,
}: ProductImageCarouselProps) {
  const [selectedImageIndex, setSelectedImageIndex] = useState(0);

  if (imageUrls.length === 0) {
    return <div className={styles.placeholder}>Aucune image</div>;
  }

  const selectedImageUrl = imageUrls[selectedImageIndex];

  return (
    <div className={styles.carousel}>
      <img src={selectedImageUrl} alt={title} className={styles.mainImage} />
      {imageUrls.length > 1 && (
        <div className={styles.thumbnails}>
          {imageUrls.map((imageUrl, imageIndex) => (
            <button
              key={`${imageUrl}-${imageIndex}`}
              type="button"
              className={`${styles.thumbnailButton} ${
                imageIndex === selectedImageIndex
                  ? styles.thumbnailButtonActive
                  : ""
              }`}
              onClick={() => setSelectedImageIndex(imageIndex)}
            >
              <img
                src={imageUrl}
                alt={`${title} ${imageIndex + 1}`}
                className={styles.thumbnailImage}
              />
            </button>
          ))}
        </div>
      )}
    </div>
  );
}
