using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Checkpoint : MonoBehaviour
{
    [SerializeField] GameObject player;

    [SerializeField] List<GameObject> checkPoints;

    [SerializeField] Vector3 vectorPoint;

    [SerializeField] float dead;

    // Update is called once per frame
    void Update()
    {
        if (player.transform.position.y < -dead)
            player.transform.position = vectorPoint;
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("point")) {
            vectorPoint = player.transform.position;
            Destroy(other.gameObject);
        }
    }
}
