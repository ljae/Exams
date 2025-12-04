import matplotlib.pyplot as plt
import numpy as np
import matplotlib.patches as patches

def generate_diagram():
    fig, ax = plt.subplots(figsize=(15, 9))
    
    # Setup
    r = 60
    theta_val = np.pi / 12  # 15 degrees for visualization
    
    # ... (coordinates calculation remains the same) ...
    # I will just copy the coordinate logic but update the plotting part with larger fonts.
    
    # Points
    O = np.array([0, 0])
    A = np.array([-r, 0])
    B = np.array([r, 0])
    
    # Coordinates calculation
    t = theta_val
    Px = r * np.cos(2*t)
    Py = r * np.sin(2*t)
    Qx = r * np.cos(np.pi - 2*t)
    Qy = r * np.sin(np.pi - 2*t)
    Rx = r * np.cos(np.pi - 3*t)
    Ry = r * np.sin(np.pi - 3*t)
    Sx = -r/3
    Sy = 0
    
    tan_t = np.tan(t)
    tan_15t = np.tan(1.5*t)
    Tx = r * (tan_15t - tan_t) / (tan_15t + tan_t)
    Ty = tan_t * (Tx + r)
    
    cot_15t = 1.0 / np.tan(1.5*t)
    tan_2t = np.tan(2*t)
    Ux = -r * cot_15t / (cot_15t + tan_2t)
    Uy = -tan_2t * Ux
    
    # Plotting
    
    # Semicircle
    arc = patches.Arc((0, 0), 2*r, 2*r, angle=0, theta1=0, theta2=180, color='black', linewidth=3)
    ax.add_patch(arc)
    ax.plot([-r, r], [0, 0], 'k-', linewidth=3) # Diameter AB
    
    # Points
    point_size = 10
    font_size = 24
    
    ax.plot([0], [0], 'ko', markersize=point_size)
    ax.text(0, -8, 'O', ha='center', va='top', fontsize=font_size, fontweight='bold')
    
    ax.plot([-r], [0], 'ko', markersize=point_size)
    ax.text(-r, -8, 'A', ha='center', va='top', fontsize=font_size, fontweight='bold')
    
    ax.plot([r], [0], 'ko', markersize=point_size)
    ax.text(r, -8, 'B', ha='center', va='top', fontsize=font_size, fontweight='bold')
    
    ax.plot([Px], [Py], 'ko', markersize=point_size)
    ax.text(Px+3, Py+3, 'P', fontsize=font_size, fontweight='bold')
    
    ax.plot([Qx], [Qy], 'ko', markersize=point_size)
    ax.text(Qx-3, Qy+3, 'Q', fontsize=font_size, fontweight='bold')
    
    ax.plot([Rx], [Ry], 'ko', markersize=point_size)
    ax.text(Rx-3, Ry+3, 'R', fontsize=font_size, fontweight='bold')
    
    ax.plot([Sx], [Sy], 'ko', markersize=point_size)
    ax.text(Sx, -8, 'S', ha='center', va='top', fontsize=font_size, fontweight='bold')
    
    ax.plot([Tx], [Ty], 'ko', markersize=point_size)
    ax.text(Tx, Ty+5, 'T', ha='center', fontsize=font_size, fontweight='bold')
    
    ax.plot([Ux], [Uy], 'ko', markersize=point_size)
    ax.text(Ux, Uy+5, 'U', ha='center', fontsize=font_size, fontweight='bold')
    
    # Lines
    ax.plot([-r, Px], [0, Py], 'b-', alpha=0.5, linewidth=2) # AP
    ax.plot([r, Rx], [0, Ry], 'b-', alpha=0.5, linewidth=2) # BR
    ax.plot([-r, Rx], [0, Ry], 'b-', alpha=0.5, linewidth=2) # AR
    ax.plot([0, Qx], [0, Qy], 'b-', alpha=0.5, linewidth=2) # OQ
    ax.plot([Qx, Rx], [Qy, Ry], 'b-', alpha=0.5, linewidth=2) # QR
    
    # f(theta) region
    theta_range = np.linspace(np.pi, np.pi - 2*t, 20)
    arc_x = r * np.cos(theta_range)
    arc_y = r * np.sin(theta_range)
    verts = list(zip(arc_x, arc_y)) + [(Rx, Ry)]
    poly_f = patches.Polygon(verts, closed=True, facecolor='skyblue', alpha=0.5)
    ax.add_patch(poly_f)
    ax.text((Qx+Rx-r)/3, (Qy+Ry)/3, 'f(θ)', fontsize=font_size, color='blue', fontweight='bold')
    
    # g(theta) triangle STU
    poly_stu = patches.Polygon([[Sx, Sy], [Tx, Ty], [Ux, Uy]], closed=True, facecolor='salmon', alpha=0.5)
    ax.add_patch(poly_stu)
    ax.text((Sx+Tx+Ux)/3, (Sy+Ty+Uy)/3, 'g(θ)', fontsize=font_size, color='red', fontweight='bold')
    
    ax.set_aspect('equal')
    ax.set_xlim(-r-15, r+15)
    ax.set_ylim(-15, r+15)
    ax.axis('off')
    
    plt.title('London Eye Geometry Problem', fontsize=28)
    plt.tight_layout()
    plt.savefig('assets/images/london_eye_geometry.png', dpi=100)
    plt.close()

if __name__ == "__main__":
    generate_diagram()
