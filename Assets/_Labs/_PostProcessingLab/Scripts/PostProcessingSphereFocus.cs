using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Camera))]
[ExecuteInEditMode]
public class PostProcessingSphereFocus : MonoBehaviour
{
    public Material material;
    public Transform focusCenter;
    [Range(0,50)]
    public float focusRange=1f;

    private void OnEnable()
    {
        GetComponent<Camera>().depthTextureMode = DepthTextureMode.Depth;
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        Vector3 pos = focusCenter.position;
        var vpMatrix = Camera.current.projectionMatrix * Camera.current.worldToCameraMatrix;
        if (material != null)
        {
            material.SetVector("_FocusCenter", new Vector4(pos.x, pos.y, pos.z, 1));
            material.SetMatrix("_InverseVPMatrix", vpMatrix.inverse);
            material.SetFloat("_FocusRange", focusRange);
            Graphics.Blit(source, destination, material);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }

    private void OnDrawGizmos()
    {
        Gizmos.DrawWireSphere(focusCenter.position, focusRange);
    }
}
