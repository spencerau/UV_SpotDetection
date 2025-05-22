import cv2
import numpy as np
import torch
from segment_anything import SamPredictor, sam_model_registry


# 1) load & HSV‐threshold the glow
img_bgr = cv2.imread("assets/uv_1.jpg")
hsv     = cv2.cvtColor(img_bgr, cv2.COLOR_BGR2HSV)
h,s,v   = cv2.split(hsv)
h = h.astype(float)/180; s = s.astype(float)/255; v = v.astype(float)/255
mask = (h>=0.55)&(h<=0.8)&(s>=0.3)&(v>=0.5)
mask = (mask*255).astype(np.uint8)

# 2) morphological open to knock off isolated pixels
mask = cv2.morphologyEx(mask, cv2.MORPH_OPEN, cv2.getStructuringElement(cv2.MORPH_ELLIPSE,(5,5)))

# 3) connected‐components area & shape filtering
n, labels, stats, centroids = cv2.connectedComponentsWithStats(mask, connectivity=8)
good = np.zeros_like(mask)
for i in range(1, n):
    area = stats[i, cv2.CC_STAT_AREA]
    if 100 < area < 5000:           # keep blobs between 100px and 5000px
        x,y,w,h = stats[i,cv2.CC_STAT_LEFT:cv2.CC_STAT_LEFT+4]
        # aspect ratio test to drop long streaks:
        ar = max(w,h)/max(min(w,h),1)
        if ar < 3:                  # roughly not too elongated
            good[labels==i] = 255

# 4) find bounding boxes around those clean blobs
contours,_ = cv2.findContours(good, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
boxes = [cv2.boundingRect(c) for c in contours]

# 5) load smaller SAM and set up
checkpoint = "models/sam_vit_b_01ec64.pth"
sam        = sam_model_registry["vit_b"](checkpoint=checkpoint)
sam.to("cuda" if torch.cuda.is_available() else "cpu")
predictor  = SamPredictor(sam)
img_rgb    = cv2.cvtColor(img_bgr, cv2.COLOR_BGR2RGB)
predictor.set_image(img_rgb)

# 6) run SAM only on those filtered boxes
out_masks = []
for (x,y,w,h) in boxes:
    box = np.array([x,y,x+w,y+h])
    masks, scores, _ = predictor.predict(box=box, multimask_output=True)
    # pick top 3 masks (already 3 by default), store all three
    out_masks.append(masks)  # masks has shape (3, H, W)

# 7) combine and save
if out_masks:
    # example: take the first box's three masks and stack as R, G, B
    masks3 = out_masks[0]  # shape (3, H, W)
    rgb_out = np.zeros((masks3.shape[1], masks3.shape[2], 3), dtype=np.uint8)
    for i in range(3):
        rgb_out[:,:,i] = (masks3[i] * 255).astype(np.uint8)
    cv2.imwrite("SAM_output_rgb.jpg", rgb_out)
else:
    cv2.imwrite("SAM_output_rgb.jpg", np.zeros((mask.shape[0], mask.shape[1],3), dtype=np.uint8))