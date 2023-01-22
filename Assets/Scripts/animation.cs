using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class animation : MonoBehaviour
{

    Animator animator;
    int isWalkingHash;
    int isRunningHash;

    // Start is called before the first frame update
    void Start()
    {
        animator = GetComponent<Animator>();
        isWalkingHash = Animator.StringToHash("isWalking");
        isRunningHash = Animator.StringToHash("isSprinting");
    }

    // Update is called once per frame
    void Update()
    {

        bool isRunning = animator.GetBool(isRunningHash);
        bool isWalking = animator.GetBool(isWalkingHash);
        bool runPressed = Input.GetKey("e");

        // if player presses w key
        if (!isWalking && (Input.GetKey("w")|| Input.GetKey("d")|| Input.GetKey("s")|| Input.GetKey("a")))
            animator.SetBool(isWalkingHash, true);
        //if player is not pressing w key
        if(isWalking && !(Input.GetKey("w") || Input.GetKey("d") || Input.GetKey("s") || Input.GetKey("a")))
            animator.SetBool(isWalkingHash, false);

        if(!isRunning&&((Input.GetKey("w") || Input.GetKey("d") || Input.GetKey("s") || Input.GetKey("a")) && runPressed))
            animator.SetBool(isRunningHash, true);

        if (isRunning && (!(Input.GetKey("w") || Input.GetKey("d") || Input.GetKey("s") || Input.GetKey("a")) || !runPressed))
            animator.SetBool(isRunningHash, false);
    }
}