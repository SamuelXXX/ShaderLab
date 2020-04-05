using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MovingOccluder : MonoBehaviour
{
    #region Settings
    public AnimationCurve animationCurve;
    public float duration;
    public Vector3 startPosition;
    public Vector3 endPosition;
    #endregion

    #region Unity Cycle
    // Start is called before the first frame update
    void Start()
    {

    }

    // Update is called once per frame
    void Update()
    {
        UpdatePosition();
    }
    #endregion

    float timer = 0f;
    bool increase = true;
    void UpdatePosition()
    {
        if (increase)
        {
            timer += Time.deltaTime / duration;
            if (timer > 1)
            {
                timer = 1f;
                increase = false;
            }
            
        }
        else
        {
            timer -= Time.deltaTime / duration;
            if (timer < 0)
            {
                timer = 0f;
                increase = true;
            }
        }
        transform.position = Vector3.Lerp(startPosition, endPosition, timer);
    }
}
