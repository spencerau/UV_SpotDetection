import cv2
import numpy as np

img = cv2.imread("assets/uv_region.jpg")
hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)

h, s, v = cv2.split(hsv)
h = h.astype(np.float32) / 180
s = s.astype(np.float32) / 255
v = v.astype(np.float32) / 255

mask = (h >= 0.55) & (h <= 0.80) & (s >= 0.3) & (v >= 0.5)
mask = (mask * 255).astype(np.uint8)

cv2.imwrite("glow_mask.jpg", mask)