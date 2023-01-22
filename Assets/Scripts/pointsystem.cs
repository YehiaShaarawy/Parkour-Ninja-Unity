using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class pointsystem : MonoBehaviour
{
    public int points;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    public void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.tag == "Coin") {
            ScoreManager.instance.AddPoint();
            Destroy(other.gameObject);
        }
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
